# module buffer
 
 this is a general purpose prototyping module used for parsing and creating files.
 contains methods for adding and deleting data into the buffer, tokenizing, cursor movements,
 file i/o, varisous search, replace methods.
 Buffer uses dynamic memory, all insertion methods will resize the buffer as needed.

## fn Buffer Buffer.new_init(&self, usz capacity = DEFAULT_CAPACITY, Allocator allocator = allocator::heap())

 Allocate memory for a new Buffer object. Panics if allocation fails
 @require !self.data() "Buffer already initialized"
 @param capacity `desired capacity for buffer, default = DEFAULT_CAPACITY`
 @param allocator `the allocator to use`
 @return `the allocated Buffer object`

## fn Buffer Buffer.temp_init(&self, usz capacity = DEFAULT_CAPACITY)

 calls new_init with temp allocator.
 @require !self.data() "Buffer already initialized"

## fn Buffer new(usz capacity = DEFAULT_CAPACITY, Allocator allocator = allocator::heap())

 function call for new object

## fn Buffer temp_new(usz capacity = DEFAULT_CAPACITY) => new(capacity, allocator::temp()) @inline;

 function call for new temp object

## fn Buffer new_file(String filepath, Allocator allocator = allocator::heap())

 will attempt to create a new buffer object and load the contents of filepath.
 if the file does not exits, an empty buffer is created with the filepath and default capacity.

## fn Buffer temp_file(String filepath) => new_file (filepath, allocator::temp() ) @inline;

 same as new_file, using the temp allocator

## fn void Buffer.chop(self, usz new_size)

 @require new_size <= self.len()

## macro usz Buffer.append_char32(&self, Char32 c)

 @require c <= 0x10ffff

## fn void Buffer.set(self, usz index, char c)

 @require index < self.len()

## fn void Buffer.insert_chars(&self, usz index, String s)

 @require index <= self.len()

## fn void Buffer.insert_string(&self, usz index, DString str)

 @require index <= self.len()

## fn void Buffer.insert_char(&self, usz index, char c)

 @require index <= self.len()

## fn usz Buffer.insert_char32(&self, usz index, Char32 c)

 @require index <= self.len()

## fn usz Buffer.insert_utf32(&self, usz index, Char32[] chars)

 @require index <= self.len()

## fn void Buffer.delete(&self, usz start, usz len = 1)

 @require start < self.len()
 @require start + len <= self.len()

## fn void Buffer.delete_range(&self, usz start, usz end)

 @require start < self.len()
 @require end < self.len()
 @require end >= start "End must be same or equal to the start"

