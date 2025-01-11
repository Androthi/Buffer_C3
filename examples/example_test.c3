module test_buffer;
import buffer;
import std::io;
import std::io::path;
import std::collections::map;


fn int main(String[] args)
{

//+ TODO these should likely go into an official test.

	Buffer trim_test = buffer::new();
	defer trim_test.free();
	trim_test.append("\n\t String with preceding and trailing white spaces\n\t ");
	trim_test.trim();
	io::printfn("trim test, there should be no white spaces\n:%s:\n", trim_test.str_view());


	Buffer buf = buffer::new();
	defer buf.free();

	Buffer buf2 = buffer::new_file("examples/test.txt");
	buf2.append("\n==============================\n");
	buf2.append_file("examples/test.txt");
	buf2.save_as("examples/test2.txt")!!;
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
	nbuf.append_file("examples/test3.txt");
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
}

