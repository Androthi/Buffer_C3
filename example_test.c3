module test_buffer;
import buffer;
import std::io;
import std::io::path;
import std::collections::map;
import std::os::win32;

Map(<String, Buffer>) buflist;

fn String Path.extract_dirname(self)
{
	String dir_path = self.dirname();
	usz! dir_start = dir_path.rindex_of_char(path::PREFERRED_SEPARATOR);
	if (try dir_start) dir_path = dir_path[dir_start+1:dir_path.len-dir_start-1];
	return dir_path;
}

fn bool! walker(Path p, bool is_dir, void*)
{
	String dir_name = p.extract_dirname();
	if (!is_dir)
	{
		if (p.has_extension("c3"))
		{
			io::printfn("Processing file :%s", p.basename());
			Buffer cur_buf = buffer::temp_file(p.path_string);
			while (true)
			{
				// we need to find module definition, make sure it is flush with line, so we know it's the correct one
				usz! index = cur_buf.find_next("module");
				if ( catch error = index)
				{
					io::printn("Error, .c3 file missing module identifier");
					return true;
				}
				usz cursor_pos = cur_buf.get_cursor();
				if (--cursor_pos > 0 ) cursor_pos--;
				if (cursor_pos > 0 && cur_buf.peek_char_at(cursor_pos)! != '\n') continue;
				break;
			}
			cur_buf.brk();
			cur_buf.span();
			String! module_name = cur_buf.get_line();
			if (catch error = module_name)
			{
				io::printn("Error, couldn't get the line from module");
				return true;
			}
			module_name = module_name.strip_end(";");

			// see if it's already in list
			Buffer cur_module;
			if (!buflist.has_key(module_name))
			{
				cur_module = buffer::new();
				cur_module.appendf ("# %s\n", module_name);
				Buffer tbuf = buflist.set_value_return( module_name, cur_module );
				buflist.set(module_name, cur_module);
			} else
			{
				cur_module = buflist.get(module_name)!;
			}
			
			cur_buf.cursor_to_bof();
			while( try cur_buf.find_next("<*"))
			{
				// we are only interested in processing '<*' that start at beginning of a line
				// after the find_next, the cursor will be pointing at the '*'
				usz cursor_pos = cur_buf.get_cursor();
				if (--cursor_pos > 0 ) cursor_pos--;
				if (cursor_pos > 0 && cur_buf.peek_char_at(cursor_pos)! != '\n') continue;
				usz start_index = cur_buf.cursor_right(1);
				usz! end_index = cur_buf.find_next("*>");
				if ( catch result = end_index){
					io::printn("Error: missing '*>'");
					break;
				}
				end_index --;
				Buffer sec = cur_buf.new_sub_buffer(start_index, end_index - start_index, allocator::temp());

				// get the function or macro definition after *>
				cur_buf.brk(); // advance to the first white space
				cur_buf.span(); // advance to the first non-white space
				String! fn_def = cur_buf.get_line();
				if (try fn_def){
					// if fn_def is module, this is top level doc
					io::printfn("found def :%s", fn_def);
					if (fn_def.starts_with("module"))
					{
						usz save_cursor = cur_module.get_cursor();
						cur_module.cursor_to_bof();
						usz inx = cur_module.cursor_right_lines(2);
						cur_module.insert(inx, "\n\n");
						cur_module.insert_buffer(inx, sec);
						cur_module.cursor_to(save_cursor);

					} else
					{
						cur_module.appendf("## %s\n", fn_def);
						cur_module.append_buffer(sec);
						cur_module.append("\n\n");
					}

					// inserting into cur_module potentially resized it and changed the pointer,
					// set it into the map again to update the pointer.
					buflist.set (module_name, cur_module);

				} else
				{
					io::printn("Error: unable to get function or macro definition");
					break;
				}
			}
		}
	} else
	{
		// for debug
		//io::printfn("Processing directory :%s", dir_name);
	}
	return false;
}

fn int main(String[] args)
{

	// a doc gen test program

	Path! path = path::temp_cwd();
	io::printfn("Working on project folder :%s", path.path_string)!!;
	(void)path.walk(&walker, null);
	io::printn("after walk");

	// save the files to /doc folder
	DString work = dstring::temp_new();
	work.append(path.path_string)!!;
	work.append(path::PREFERRED_SEPARATOR);
	work.append("docs");
	work.append(path::PREFERRED_SEPARATOR);
	String doc_folder = work.tcopy_str();
	buflist.@each(;String key, Buffer value)
	{
		work.clear();
		work.append (key);
		work.delete_range(0, 6); // remove "module" from name
		work.insert_at (0, doc_folder);
		work.append (".md");
		io::printfn("saving as :%s", work.str_view());
		value.save_as (work.str_view())!!;
	};
	return 0;
}


/*
// old test data.
//+ TODO these should likely go into an official test.

	Buffer trim_test = buffer::new();
	defer trim_test.free();
	trim_test.append("\n\t String with preceding and trailing white spaces\n\t ");
	trim_test.trim();
	io::printfn("trim test, there should be no white spaces\n:%s:\n", trim_test.str_view());


	Buffer buf = buffer::new();
	defer buf.free();

	Buffer buf2 = buffer::new_file("test.txt");
	buf2.append("\n==============================\n");
	buf2.append_file("test.txt");
	buf2.save_as("test2.txt")!!;
	buf2.replace_chars('7', '#');

	// io::printn("Testing insertf\n");
	buf.append_buffer(buf2);
	buf.insertf(30, "@%d@", 6666);
	// io::printn(buf.str_view());

	// testing sub_string and sub_buffer
	io::printn("\ntesting sub_buffer, delete\n");
	Buffer nbuf = buffer::new(17);
	defer nbuf.free();
	(void)buf.sub_buffer(30, 37, &nbuf);
	nbuf.delete(7, 10);
	io::printn(nbuf.str_view());

	Buffer nabuf = nbuf.new_sub_buffer(1, 10);
	defer nabuf.free();
	io::printf("nabuf len :%d\ndat :%s\n",nabuf.len(), nabuf.str_view());

	io::printn("\ntesting sub_string, new_sub_string\n");
	DString str;
	defer str.free();
	(void)nbuf.sub_string(7, 5, &str);
	io::printf("str len = %d\nstr = %s\n", str.len(), str.str_view());
	DString temp = nbuf.new_sub_string(7, 5);
	defer temp.free();
	io::printf("temp :%s\n", temp.str_view());

	// testing tokenizer
	nbuf.clear();
	nbuf.append_file("test3.txt");
	io::printn("===================================");
	io::printn(nbuf.str_view());
	io::printn("=============================");
	nbuf.cursor_to(0);
	while (true)
	{
		String! result = nbuf.next_token();
		if( catch excuse = result )
		{
			io::printfn("\nEnd loop, excuse: %s", excuse);
			break;
		}
		io::printf("\ntoken:%s", result);
	}
	
	io::printf("nbuf len = %d\n", nbuf.len());
	nbuf.cursor_to(50);
	nbuf.cursor_to_bol(); // should be at '"'
	char! c = nbuf.get_char();
	if(try c) io::printf("got char :%c\n", c);
	nbuf.cursor_to_bof();
	(void)io::printf("line :%s\n", nbuf.get_line());
	(void)io::printf("line :%s\n", nbuf.get_line());
	nbuf.cursor_to_bof();
	usz! index = nbuf.find("string");
	if (try index)
	{
		io::printfn("found 'string' at index %d\n", index);
		nbuf.cursor_to(index);
		if( try String tkn = nbuf.next_token()) io::printfn("got token :%s", tkn);
	}
	nbuf.replace_string("string", "replacement");
	io::printf("\nafter replace:\n%s\n", nbuf.str_view());

	nbuf.cursor_to_bof();
	while(try pos = nbuf.find_next("find")) io::printfn("found 'find' at index:%d", pos);

	return 0;
*/
