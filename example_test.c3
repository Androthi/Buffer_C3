module buffer_test;
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
	//io::printn(p.str_view());
	if (!is_dir)
	{
		if (p.has_extension("c3"))
		{
			String dir_name = p.extract_dirname();
			// see if it's already in list
			Buffer cur_buf = buffer::temp_file(p.path_string);
			usz! index = cur_buf.find("module");
			if ( catch error = index)
			{
				io::printn("Error, .c3 file missing module identifier");
				return true;
			}
			cur_buf.span();
			cur_buf.brk();
			String! module_name = cur_buf.get_cursor_line();
			if (catch error = module_name)
			{
				io::printn("Error, couldn't get the line from module");
				return true;
			}
			module_name = module_name.strip_end(";");

			Buffer cur_module;
			if (!buflist.has_key(module_name))
			{
				cur_module = buffer::new();
				cur_module.appendf ("# %s\n\n", module_name);
				buflist.set(module_name, cur_module);
			} else
			{
				cur_module = buflist.get(module_name)!;
			}
			
			cur_buf.cursor_to_bof();
			while( try cur_buf.find_next("<*"))
			{
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
					cur_module.appendf("## %s\n", fn_def);
					cur_module.append_buffer(sec);
					cur_module.append("\n\n");
				} else
				{
					io::printn("Error: unable to get function or macro definition");
					break;
				}
			}
			//io::printfn("Directory :%s\nFile Name :%s\nModule Name :%s", dir_name, p.basename(), module_name);
		}
	}
	return false;
}

fn int main(String[] args)
{

	// a doc gen test program

	Path! path = path::temp_cwd();
	(void)path.walk(&walker, null);


	
	//PathList list = path::new_ls(path)!!;
 	//foreach(p : list)
	//{
	//	if (p.has_extension("c3"))
	//	{

	//	}
	//	std::io::printn(p.str_view());
	//}

/*
	Buffer source = buffer::new_file("Buffer/buffer.c3");
	defer source.free();
	Buffer dest = buffer::new();
	dest.set_filepath("doc_test.md");
	defer dest.free();
	dest.append("# Auto Document Generator Test\n\n");
	defer dest.save()!!;

	//extract sub_buffers for every <* *> match
	while( try source.find_next("<*"))
	{
		usz start_index = source.cursor_right(1);
		usz! end_index = source.find_next("*>");
		if ( catch result = end_index){
			io::printn("Error: missing '*>'");
			break;
		}
		end_index --;
		Buffer sec = source.new_sub_buffer(start_index, end_index - start_index, allocator::temp());

		// get the function or macro definition after *>
		source.brk(); // advance to the first white space
		source.span(); // advance to the first non-white space
		String! fn_def = source.get_line();
		if (try fn_def){
			dest.appendf("## %s\n", fn_def);
			dest.append_buffer(sec);
			dest.append("\n\n");
		} else
		{
			io::printn("Error: unable to get function or macro definition");
			break;
		}
	}
*/
	return 0;
}


/*
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
