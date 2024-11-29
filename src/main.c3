module buffer_test;
import buffer;
import std::io;

fn int main(String[] args)
{

	Buffer trim_test = buffer::new();
	defer trim_test.free();
	trim_test.append("\n\t String with preceding and trailing white spaces\n\t ");
	trim_test.trim();
	io::printfn("trim test, there should be no white spaces\n:%s:\n\n", trim_test.str_view());


	Buffer buf = buffer::new();

	Buffer buf2 = buffer::new_file("test.txt");
	buf2.append("\n==============================\n");
	buf2.append_file("test.txt");
	//buf2.insert_file(30, "test3.txt");
	buf2.save_as("test2.txt")!!;
	
	//io::printfn("len = %d", buf2.len());
	buf2.replace_chars('7', '#');

	//buf.append_chars("^appending some chars");
	//buf.append('*');
	buf.append_buffer(buf2);
	//buf.insertf(124, "\n[[insertf string @124]]");
	buf.insertf(30, "@%d@", 6666);
	Buffer nbuf;// = buffer::new();
	(void)buf.sub_buffer(30, 37, &nbuf);
	nbuf.delete(7, 10);
	DString str; // = dstring::new();
	(void)nbuf.sub_string(7, 5, &str);
	io::printf("str len = %d\nstr = %s\n", str.len(), str.str_view());
	io::printn(buf.str_view());
	io::printn(nbuf.str_view());

	Buffer temp = nbuf.new_sub_buffer(1, 10);
	io::printf("\n:%s", temp.str_view());

	temp.free();
	str.free();
	buf.free();
	buf2.free();
	nbuf.free();
	return 0;
}
