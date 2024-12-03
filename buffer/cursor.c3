module buffer;
import std::io;

macro usz Buffer.cursor_to_eof(&self)
{
	self.cursor_to(self.len());
}

macro usz Buffer.cursor_to_bof(&self)
{
	self.cursor_to(0);
}

fn usz Buffer.cursor_to(&self, usz index)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	if (index > data.len) index = data.len;
	data.cursor = index;
	return data.cursor;
}

fn usz Buffer.cursor_right(&self, usz n)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	if ((data.cursor += n) > data.len) data.cursor = data.len;
	return data.cursor;
}

fn usz Buffer.cursor_left(&self, usz n)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	if ((isz)(data.cursor -= n) < 0) data.cursor = 0;
	return data.cursor;
}

// returns index, maybe optional return with errors.
fn usz Buffer.cursor_to_bol(&self)
{
	if (!*self) return 0;
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

fn usz Buffer.span(&self, Cset set = WHITE_SPACES)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	while (data.cursor < data.len)
	{
		if (!char_in_cset(data.chars[data.cursor], set)) break;
		data.cursor++;
	}
	return data.cursor;
}

fn usz Buffer.brk(&self, Cset set = WHITE_SPACES)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	while (data.cursor < data.len)
	{
		if (char_in_cset(data.chars[data.cursor], set)) break;
		data.cursor++;
	}
	return data.cursor;	
}

//= NOTE: these will likely get their own files later

fn char! Buffer.get_char(&self)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	if (data.cursor == data.len) return BufferError.EOF?;
	return data.chars[data.cursor++];
}

fn String! Buffer.get_line(&self, bool entire_line = true)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	if (data.cursor == data.len) return BufferError.EOF?;
	usz start = data.cursor;
	if (entire_line) start = self.cursor_to_bol();
	usz end = self.cursor_to_eol();
	if (data.cursor < data.len) data.cursor++; // advance 1 char beyond EOL.
	return (String)data.chars[start:end-start];
}

macro Buffer.get_cursor_line(&self)
{
	self.get_line(false)!;
}

fn String! Buffer.get_line_from(&self, usz start)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	if (start >= data.len) return BufferError.EOF?;
	usz end = start;
	while (end < data.len)
	{
		if (char_in_cset(data.chars[end], "\n\r")) break;
		end++;
	}
	return (String)data.chars[start:end-start];
}

fn usz! Buffer.find_next(&self, String needle, bool case_sensitive = true)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	usz! index = self.find(needle, data.cursor, case_sensitive);
	if( try index ){
		data.cursor = ++index; //need to be 1 past find index for next find pass
		return data.cursor-1;
	} else {
		return BufferError.EOF?;
	}
}

macro usz! Buffer.ifind_next(&self, String needle)
{
	self.find_next(needle, true);
}

fn usz! Buffer.find(&self, String needle, usz start_from = 0, bool case_sensitive = true)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	usz needle_len = needle.len;
	if (start_from > data.len || data.len == 0) return BufferError.EOF?;

	if (needle_len > 0 && data.len - start_from >= needle_len)
	{
		String source = (String)data.chars[start_from..data.len];
			
		if (case_sensitive)
		{
			char first = needle[0];
			foreach (i, c: source[..^needle_len])
			{
				if (c == first && source[i:needle_len] == needle) return i + start_from;
			}
		} else
		{
			@pool(data.allocator)
			{
				String tneedle = needle.temp_ascii_to_lower();
				String tsource = source.temp_ascii_to_lower();
				char first = tneedle[0];
				foreach (i, c: tsource[..^needle_len])
				{
					if (c == first && tsource[i:needle_len] == tneedle) return i + start_from;
				}
			};
		}
	}
	return BufferError.EOF?;
}

macro usz! Buffer.ifind(&self, String needle, usz start_from = 0)
{
	self.find(needle, start_from, false);
}