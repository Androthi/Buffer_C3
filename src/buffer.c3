module buffer;
import std::io;
import std::io::path;
import std::io::file;

distinct Buffer (OutStream) = void*;
//distinct Buffer = void*;

const usz MIN_CAPACITY @private = 16;
const usz DEFAULT_CAPACITY @private = 4096;

struct BufferData @private
{
	Allocator allocator;
	usz len;
	usz capacity;
	usz cursor;
	String filepath;
	char[*] chars;
}

//+ Init/Memory methods =======================================================

<*
 @require !self.data() "Buffer already initialized"
*>
fn Buffer Buffer.new_init(&self, usz capacity = DEFAULT_CAPACITY, Allocator allocator = allocator::heap())
{
	if (capacity < MIN_CAPACITY) capacity = MIN_CAPACITY;
	BufferData* data = allocator::alloc_with_padding(allocator, BufferData, capacity)!!;
	data.allocator = allocator;
	data.len = 0;
	data.capacity = capacity;
	data.filepath = String{};
	return *self = (Buffer)data;
}

<*
 @require !self.data() "Buffer already initialized"
*>
fn Buffer Buffer.temp_init(&self, usz capacity = DEFAULT_CAPACITY)
{
	self.new_init(capacity, allocator::temp()) @inline;
	return *self;
}

fn Buffer new(usz capacity = DEFAULT_CAPACITY, Allocator allocator = allocator::heap())
{
	return Buffer{}.new_init(capacity, allocator);
}

fn Buffer temp_new(usz capacity = DEFAULT_CAPACITY) => new(capacity, allocator::temp()) @inline;

fn Buffer new_file(String filepath)
{
	usz len = file::get_size(filepath) ?? DEFAULT_CAPACITY;
	Buffer buf = Buffer{}.new_init(len, allocator::heap());
	buf.open_file(filepath);
	return buf;
}

fn Buffer temp_file(String filepath)
{
	usz len = file::get_size(filepath) ?? DEFAULT_CAPACITY;
	Buffer buf = Buffer{}.new_init(len, allocator::temp());
	buf.open_file(filepath);
	return buf;
}

fn void Buffer.set_filepath(&self, String filepath)
{
	if (!*self) *self = new();
	BufferData* data = self.data();
	data.filepath = filepath;
}

//	NOTE: use append_file or insert_file if it is desired to preserve current buffer contents
fn void Buffer.open_file(&self, String filepath)
{
	usz len = file::get_size(filepath) ?? 0;
	BufferData* data = self.data();
	if(len)
	{
		self.reserve(len);
		data.len = file::load_buffer(filepath, data.chars[:len]).len ?? 0;
	}
	data.filepath = filepath;
}

// append_file doesn't change the filepath unless it's empty
fn void Buffer.append_file(&self, String filepath)
{
	self.insert_file(self.len(), filepath);
}

// insert at index, or at eof
fn void Buffer.insert_file(&self, usz index, String filepath)
{
	if (!filepath) return;
	usz file_len = file::get_size(filepath) ?? 0;
	self.reserve(file_len);
	BufferData* data = self.data();
	if (data.filepath.len == 0) data.filepath = filepath;
	if (file_len == 0) return;
	usz len = data.len;
	index = min(index, len);
	char* start = data.chars[index:file_len].ptr; // area to insert into
	mem::move(start + file_len, start, len - index); // move existing data
	data.len += file::load_buffer(filepath, data.chars[index:file_len]).len ?? 0;
}

//+ TODO: ? object should allocate a new string for filepath, and free it each
//			time it is changed and during final free. ?
fn void Buffer.free(&self)
{
	if (!*self) return;
	BufferData* data = self.data();
	if (!data) return;
	//- TODO: if there is a filename string, free it
	allocator::free(data.allocator, data);
	*self = (Buffer)null;
}

fn void Buffer.reserve(&self, usz addition)
{
	BufferData* data = self.data();
	if (!data)
	{
		*self = buffer::new(addition);
		return;
	}
	usz len = data.len + addition;
	if (data.capacity >= len) return;
	usz new_capacity = data.capacity * 2; //- NOTE: should this be *2 here?
	if (new_capacity < MIN_CAPACITY) new_capacity = MIN_CAPACITY;
	while (new_capacity < len) new_capacity *= 2;
	data.capacity = new_capacity;
	*self = (Buffer)allocator::realloc(data.allocator, data, BufferData.sizeof + new_capacity);
}

//+ File saving methods =======================================================

//- TODO: save should return an error if there is an empty string for filepath
fn usz Buffer.save(&self)
{
	usz bytes_written;
	BufferData* data = self.data();
	if (data.filepath.len > 0 && data.len > 0)
	{
		File file = file::open(data.filepath, "wb")!!;
		defer (void)file.close();
		bytes_written = file.write(data.chars[0:data.len]) ?? 0;
	}
	return bytes_written;
}

fn usz Buffer.save_as(&self, String filepath)
{
	BufferData*data = self.data();
	data.filepath = filepath; //- TODO: ? may require a string free here
	return self.save();
}

//+ Info/View/Maintenence methods =============================================

fn BufferData* Buffer.data(self) @inline @private
{
	return (BufferData*)self;
}

fn usz Buffer.capacity(self)
{
	if (!self) return 0;
	return self.data().capacity;
}

fn String Buffer.get_filepath(self)
{
	BufferData* data = self.data();
	return self.data().filepath;
}

fn usz Buffer.len(&self) @dynamic
{
	if (!*self) return 0;
	return self.data().len;
}

fn String Buffer.str_view(self)
{
	BufferData* data = self.data();
	if (!data) return "";
	return (String)data.chars[:data.len];
}

fn ZString Buffer.zstr_view(&self)
{
	BufferData* data = self.data();
	if (!data) return "";
	if (data.capacity == data.len)
	{
		self.reserve(1);
		data = self.data();
		data.chars[data.len] = 0;
	}
	else if (data.chars[data.len] != 0)
	{
		data.chars[data.len] = 0;
	}
	return (ZString)&data.chars[0];
}

fn void Buffer.clear(self)
{
	if (!self) return;
	self.data().len = 0;
}

<*
 @require new_size <= self.len()
*>
fn void Buffer.chop(self, usz new_size)
{
	if (!self) return;
	self.data().len = new_size;
}

//+ Data appent/insert methods ================================================

macro void Buffer.append(&self, value)
{
	var $Type = $typeof(value);
	$switch ($Type)
		$case char:
		$case ichar:
			self.append_char(value);
		$case DString:
			self.append_string(value);
		$case String:
			self.append_chars(value);
		$case Char32:
			self.append_char32(value);
		$default:
			$switch
				$case $defined((Char32)value):
					self.append_char32((Char32)value);
				$case $defined((String)value):
					self.append_chars((String)value);
				$default:
					$error "Unsupported type for append – use appendf instead.";
			$endswitch
	$endswitch
}

fn void Buffer.append_chars(&self, String str)
{
	self.insert_chars(self.len(), str);
}

fn void Buffer.append_char(&self, char c)
{
	self.insert_char(self.len(), c);
}

fn void Buffer.append_string(&self, DString str)
{
	if (!str) return;
	self.append(str.str_view());
}

<*
 @require c <= 0x10ffff
*>
fn usz Buffer.append_char32(&self, Char32 c)
{
	usz n = self.insert_char32(self.len(), c);
	return n;
}

fn void! out_string_append_fn(void* data, char c) @private
{
	Buffer* s = data;
	s.append_char(c);
}

fn usz! Buffer.appendf(&self, String format, args...) @maydiscard
{
	if (!self.data()) self.new_init(format.len + 20);
	@pool(self.data().allocator)
	{
		Formatter formatter;
		formatter.init(&out_string_append_fn, self);
		return formatter.vprintf(format, args);
	};
}

fn usz Buffer.append_utf32(&self, Char32[] chars)
{
	usz n = self.append_utf32(chars);
	return n;
}

fn void Buffer.append_repeat(&self, char c, usz times)
{
	if (times == 0) return;
	self.reserve(times);
	BufferData* data = self.data();
	for (usz i = 0; i < times; i++)
	{
		data.chars[data.len++] = c;
	}
}


//- NOTE: maybe ? insert methods will eventually use cursor as insertion index ?

<*
 @require index < self.len()
*>
fn void Buffer.set(self, usz index, char c)
{
	self.data().chars[index] = c;
}

fn usz! Buffer.write(&self, char[] buffer) @dynamic
{
	self.append_chars((String)buffer);
	return buffer.len;
}

fn void! Buffer.write_byte(&self, char c) @dynamic
{
	self.append_char(c);
}

fn usz! Buffer.read_from_stream(&self, InStream reader)
{
	if (&reader.available)
	{
		usz total_read = 0;
		while (usz available = reader.available()!)
		{
			self.reserve(available);
			BufferData* data = self.data();
			usz len = reader.read(data.chars[data.len..(data.capacity - 1)])!;
			total_read += len;
			data.len += len;
		}
		return total_read;
	}
	usz total_read = 0;
	while (true)
	{
		// Reserve at least 16 bytes
		self.reserve(16);
		BufferData* data = self.data();
		// Read into the rest of the buffer
		usz read = reader.read(data.chars[data.len..(data.capacity - 1)])!;
		data.len += read;
		// Ok, we reached the end.
		if (read < 16) return total_read;
		// Otherwise go another round
	}
}

macro void Buffer.insert(&self, usz index, value)
{
	var $Type = $typeof(value);
	$switch ($Type)
		$case char:
		$case ichar:
			self.insert_char(index, value);
		$case DString:
			self.insert_string(index, value);
		$case String:
			self.insert_chars(index, value);
		$case Char32:
			self.insert_char32(index, value);
		$default:
			$switch
				$case $defined((Char32)value):
					self.insert_char32(index, (Char32)value);
				$case $defined((String)value):
					self.insert_chars(index, (String)value);
				$default:
					$error "Unsupported type for insert";
			$endswitch
	$endswitch
}

<*
 @require index <= self.len()
*>
fn void Buffer.insert_chars(&self, usz index, String s)
{
	if (s.len == 0) return;
	if (!*self) *self = new();
	self.reserve(s.len);
	BufferData* data = self.data();
	usz len = self.len();
	if (data.chars[:len].ptr == s.ptr)
	{
		// Source and destination are the same: nothing to do.
		return;
	}
	index = min(index, len);
	data.len += s.len;

	char* start = data.chars[index:s.len].ptr; // area to insert into
	mem::move(start + s.len, start, len - index); // move existing data
	switch
	{
		case s.ptr <= start && start < s.ptr + s.len:
			// Overlapping areas.
			foreach_r (i, c : s)
			{
				data.chars[index + i] = c;
			}
		case start <= s.ptr && s.ptr < start + len:
			// Source has moved.
			mem::move(start, s.ptr + s.len, s.len);
		default:
			mem::move(start, s, s.len);
	}
}

<*
 @require index <= self.len()
*>
fn void Buffer.insert_string(&self, usz index, DString str)
{
	if (!str) return;
	self.insert(index, str.str_view());
}

<*
 @require index <= self.len()
*>
fn void Buffer.insert_char(&self, usz index, char c)
{
	self.reserve(1);
	BufferData* data = self.data();

	char* start = &data.chars[index];
	mem::move(start + 1, start, self.len() - index);
	data.chars[index] = c;
	data.len++;
}

<*
 @require index <= self.len()
*>
fn usz Buffer.insert_char32(&self, usz index, Char32 c)
{
	char[4] buffer @noinit;
	char* p = &buffer;
	usz n = conv::char32_to_utf8_unsafe(c, &p);

	self.reserve(n);
	BufferData* data = self.data();

	char* start = &data.chars[index];
	mem::move(start + n, start, self.len() - index);
	data.chars[index:n] = buffer[:n];
	data.len += n;

	return n;
}

<*
 @require index <= self.len()
*>
fn usz Buffer.insert_utf32(&self, usz index, Char32[] chars)
{
	usz n = conv::utf8len_for_utf32(chars);
	
	self.reserve(n);
	BufferData* data = self.data();

	char* start = &data.chars[index];
	mem::move(start + n, start, self.len() - index);

	char[4] buffer @noinit;

	foreach(c : chars)
	{
		char* p = &buffer;
		usz m = conv::char32_to_utf8_unsafe(c, &p);
		data.chars[index:m] = buffer[:m];
		index += m;
	}

	data.len += n;

	return n;
}


//+ Buffer editing ============================================================

<*
 @require start < self.len()
 @require start + len <= self.len()
*>
fn void Buffer.delete(&self, usz start, usz len = 1)
{
	if (!len) return;
	BufferData* data = self.data();
	usz new_len = data.len - len;
	if (new_len == 0)
	{
		data.len = 0;
		return;
	}
	usz len_after = data.len - start - len;
	if (len_after > 0)
	{
		data.chars[start:len_after] = data.chars[start + len:len_after];
	}
	data.len = new_len;
}

<*
 @require start < self.len()
 @require end < self.len()
 @require end >= start "End must be same or equal to the start"
*>
fn void Buffer.delete_range(&self, usz start, usz end)
{
	self.delete(start, end - start + 1);
}

//+ Copying ===================================================================

fn Buffer Buffer.copy(self, Allocator allocator = null)
{
	if (!self)
	{
		if (allocator) return new(0, allocator);
		return (Buffer)null;
	}
	BufferData* data = self.data();
	if (!allocator) allocator = allocator::heap();
	Buffer new_buffer = new(data.capacity, allocator);
	mem::copy((char*)new_buffer.data(), (char*)data, BufferData.sizeof + data.len);
	return new_buffer;
}

fn Buffer Buffer.temp_copy(&self) => self.copy(allocator::temp());

fn ZString Buffer.copy_zstr(self, Allocator allocator = allocator::heap())
{
	usz str_len = self.len();
	if (!str_len)
	{
		return (ZString)allocator::calloc(allocator, 1);
	}
	char* zstr = allocator::malloc(allocator, str_len + 1);
	BufferData* data = self.data();
	mem::copy(zstr, &data.chars, str_len);
	zstr[str_len] = 0;
	return (ZString)zstr;
}

fn String Buffer.copy_str(self, Allocator allocator = allocator::heap())
{
	return (String)self.copy_zstr(allocator)[:self.len()];
}

fn String Buffer.temp_copy_str(self) => self.copy_str(allocator::temp()) @inline;

fn Char32[] Buffer.copy_utf32(&self, Allocator allocator = allocator::heap())
{
	return self.str_view().to_utf32(allocator) @inline!!;
}

// Comparing/Branching ========================================================

fn bool Buffer.equals(self, Buffer other_buffer)
{
	BufferData *buf1 = self.data();
	BufferData *buf2 = other_buffer.data();
	if (buf1 == buf2) return true;
	if (!buf1) return buf2.len == 0;
	if (!buf2) return buf1.len == 0;
	usz buf1_len = buf1.len;
	if (buf1_len != buf2.len) return false;
	for (int i = 0; i < buf1_len; i++)
	{
		if (buf1.chars[i] != buf2.chars[i]) return false;
	}
	return true;
}

fn bool Buffer.less(self, Buffer other_buffer)
{
	BufferData* buf1 = self.data();
	BufferData* buf2 = other_buffer.data();
	if (buf1 == buf2) return false;
	if (!buf1) return buf2.len != 0;
	if (!buf2) return buf1.len == 0;
	usz buf1_len = buf1.len;
	usz buf2_len = buf2.len;
	if (buf1_len != buf2_len) return buf1_len < buf2_len;
	for (int i = 0; i < buf1_len; i++)
	{
		if (buf1.chars[i] >= buf2.chars[i]) return false;
	}
	return true;
}
