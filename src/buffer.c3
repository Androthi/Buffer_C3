module buffer;
import std::io;
import std::io::file;
import std::core::string;

distinct Buffer (OutStream) = void*;
//distinct Buffer = void*;

const usz MIN_CAPACITY @private = 16;
const usz DEFAULT_CAPACITY @private = 4096;

fault BufferError
{
	NULL_BUFFER,
	NO_FILENAME,
	SAVE_FAILED,
	INDEX_OUT_OF_RANGE,
	OPERATION_FAILED,
}

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
 Allocate memory for a new Buffer object. Panics if allocation fails
 @require !self.data() "Buffer already initialized"
 @param capacity `desired capacity for buffer, default = DEFAULT_CAPACITY`
 @param allocator `the allocator to use`
 @return `the allocated Buffer object`
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
	//buf.open_file(filepath);
	return buf.open_file(filepath);
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

macro void Buffer.append_file(&self, String filepath)
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
	self.adjust_for_insert (index, file_len);
	data.len += file::load_buffer(filepath, data.chars[index:file_len]).len ?? 0;
}

fn void Buffer.free(&self)
{
	if (!*self) return;
	BufferData* data = self.data();
	if (!data) return;
	allocator::free(data.allocator, data);
	*self = (Buffer)null;
}

fn void Buffer.reserve(&self, usz addition) @private
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

fn void Buffer.adjust_for_insert(&self, usz index, usz len) @private
{
	// should make this a BufferData method?
	BufferData* data = self.data();
	if (index == data.len) return; // we are at EOF, nothing to move
	char* start = &data.chars[index];
	mem::move (start + len, start, self.len() - index);
}

//+ File saving methods =======================================================

//- TODO: save should return an error if there is an empty string for filepath
fn void! Buffer.save(&self)
{
	BufferData* data = self.data();
	if (!data) return BufferError.NULL_BUFFER?;
	if (data.filepath.len == 0) return BufferError.NO_FILENAME?;
	if ( catch error = file::save(data.filepath, data.chars[0:data.len])) return BufferError.SAVE_FAILED?;
}

fn void! Buffer.save_as(&self, String filepath)
{
	BufferData*data = self.data();
	if (!data) return BufferError.NULL_BUFFER?;
	data.filepath = filepath;
	self.save()!;
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
