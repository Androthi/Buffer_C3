module buffer;
import std::io;

macro void Buffer.cursor_to_eof(&self)
{
	self.cursor_to(self.len());
}

macro void Buffer.cursor_to_bof(&self)
{
	self.cursor_to(0);
}

fn void Buffer.cursor_to(&self, usz index)
{
	if (!*self) return;
	BufferData* data = self.data();
	if (index > data.len) index = data.len;
	data.cursor = index;
}

fn void Buffer.cursor_right(&self, usz n)
{
	if (!*self) return;
	BufferData* data = self.data();
	if ((data.cursor += n) > data.len) data.cursor = data.len;
}

fn void Buffer.cursor_left(&self, usz n)
{
	if (!*self) return;
	BufferData* data = self.data();
	if ((isz)(data.cursor -= n) < 0) data.cursor = 0;
}

// returns index, maybe optional return with errors.
fn usz Buffer.cursor_to_bol(&self)
{
	if (!*self) 0;
	BufferData* data = self.data();
	if (data.cursor == 0) return 0;

	// if currently at EOL, don't count it.
	if (data.chars[data.cursor] == '\n') data.cursor--;
	if (data.cursor == 0) return 0;
	if (data.chars[data.cursor] == '\r') data.cursor--; //hate dealing with DOS crap.

	while (data.cursor > 0)
	{
		if (char_in_cset(data.chars[data.cursor], "\n\r")) break;
		data.cursor--;
	}

	// we are at the EOL of the previous line, if any. advance the cursor to the beginning of the actual text.
	if( data.cursor == 0) return 0;
	if (data.chars[data.cursor] == '\r') data.cursor++;
	return ++data.cursor;
}

fn usz Buffer.cursor_to_eol(&self)
{
	if (!*self) return 0;
	BufferData* data = self.data();

	while (data.cursor < data.len)
	{
		if (char_in_cset(data.chars[data.cursor], "\n\r")) break;
		data.cursor++;
	}
	return data.cursor;
}


//= NOTE: these will likely get their own files later

fn char Buffer.get_char(&self)
{
	//+ TODO do i want to add optional return, null buffer, eof. ?? 
	if (!*self) return 0;
	BufferData* data = self.data();
	if (data.cursor == data.len) return 0;
	return data.chars[data.cursor++];
}

fn String Buffer.get_line(&self)
{
	//+ TODO do i want to add optional return, null buffer, eof. ?? 
	if (!*self) return String{};
	BufferData* data = self.data();
	usz start = self.cursor_to_bol();
	usz end = self.cursor_to_eol();
	if (data.cursor < data.len) data.cursor++; // advance 1 char beyond EOL.
	return (String)data.chars[start:end-start];
}

//+ TODO: add case_sensitive option
fn usz! Buffer.find(&self, String needle, usz start_from = 0)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	usz needle_len = needle.len;
	if (start_from > data.len || data.len == 0) return BufferError.EOF?;

	if (needle_len > 0 && data.len - start_from >= needle_len)
	{
		io::printn("starting");
		String source = (String)data.chars[start_from:data.len];
		char first = needle[0];
		foreach (i, c: source[..^needle_len])
		{
			if (c == first && source[i:needle_len] == needle) return i;
		}
	}
	return BufferError.EOF?;
}