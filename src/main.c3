module buffer_test;
import buffer;
import std::io;

fn int main(String[] args)
{
	DString str = dstring::new("Hello World");
	
	io::printn("Hello, World!");
	Buffer buf = buffer::new();
	io::printn( buf.capacity());
	buf.append("COG");
	io::printn( buf.str_view());
	buf.set(1, 'A');
	io::printn( buf.str_view());
	buf.append( str );
	io::printn(buf.str_view());

	buf.clear();

	buf.appendf("Hello in %s", str);
	io::printn(buf.str_view());

	Buffer buf2 = buffer::new_file("test.txt");
	buf2.append_file("test.txt");
	buf2.append_file("test.txt");
	buf2.insert_file(30, "test3.txt");
	buf2.save_as("test2.txt");
	
	io::printfn("len = %d", buf2.len());
	io::printn(buf2.str_view());

	buf.append_chars("appending some chars");
	io::printn(buf.str_view());
	buf.free();
	buf2.free();
	return 0;
}
