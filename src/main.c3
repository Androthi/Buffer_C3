module buffer_test;
import buffer;
import std::io;

fn int main(String[] args)
{
	
	Buffer buf = buffer::new();

	Buffer buf2 = buffer::new_file("test.txt");
	buf2.append("\n==============================\n");
	buf2.append_file("test.txt");
	//buf2.insert_file(30, "test3.txt");
	buf2.save_as("test2.txt")!!;
	
	//io::printfn("len = %d", buf2.len());
	//buf2.replace_chars('7', '#');

	//buf.append_chars("^appending some chars");
	//buf.append('*');
	buf.append_buffer(buf2);
	//buf.insertf(124, "\n[[insertf string @124]]");
	buf.insertf(30, "@%d@", 6666);
	io::printn(buf.str_view());
	buf.free();
	buf2.free();
	return 0;
}
