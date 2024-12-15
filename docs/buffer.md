## module buffer


``` 
	this is a general purpose prototyping module used for parsing and creating files.
	contains methods for adding and deleting data into the buffer, tokenizing, cursor movements,
	file i/o, varisous search, replace methods.
	Buffer uses dynamic memory, all insertion methods will resize the buffer as needed.
```

### fn Buffer Buffer.new_init(&self, usz capacity = DEFAULT_CAPACITY, Allocator allocator = allocator::heap())

```
	Allocate memory for a new Buffer object. Panics if allocation fails
	@require !self.data() "Buffer already initialized"
	@param capacity `desired capacity for buffer, default = DEFAULT_CAPACITY`
	@param allocator `the allocator to use`
	@return `the allocated Buffer object`
```

### fn Buffer Buffer.temp_init(&self, usz capacity = DEFAULT_CAPACITY)

```
	calls new_init with temp allocator.
	@require !self.data() "Buffer already initialized"
```

### fn Buffer new(usz capacity = DEFAULT_CAPACITY, Allocator allocator = allocator::heap())

```
	function call for new object
```

### fn Buffer temp_new(usz capacity = DEFAULT_CAPACITY) => new(capacity, allocator::temp()) @inline;

```
	function call for new temp object
```

### fn Buffer new_file(String filepath, Allocator allocator = allocator::heap())

```
	will attempt to create a new buffer object and load the contents of filepath.
	if the file does not exits, an empty buffer is created with the filepath and default capacity.
```

### fn Buffer temp_file(String filepath) => new_file (filepath, allocator::temp() ) @inline;

```
	same as new_file, using the temp allocator
```

### fn void Buffer.set_filepath(&self, String filepath)

```
	sets a new internal filepath for this object.
	this is the file created with the save() method.
```

### fn void Buffer.open_file(&self, String filepath)

```
	tries to open the file filepath and load it into the buffer.
	filepath is set as the internal filename for the buffer.
	this will replace existing content in the buffer.
	use append_file() to keep the contents of the buffer.
```

### macro void Buffer.append_file(&self, String filepath)

```
	will try to open filepath and append it at the end of the buffer.
	this macro is a wrapper around insert_file method.
```

### fn void Buffer.insert_file(&self, usz index, String filepath)

```
	tries to insert a file at the given index.
	if tere is no filepath specified for the buffer, sets filepath as the buffer's filepath.
```

### fn void Buffer.free(&self)

```
	free memory of buffer
```

### fn void Buffer.reserve(&self, usz addition) @private

```
	private method to reserve addition amount of bytes in the buffer memory.
```

### fn void Buffer.adjust_for_insert(&self, usz index, usz len) @private

```
	private helper metod for creating a len amount of space at index for
	inserting new data.
```

### fn void! Buffer.save(&self)

```
	saves te contents of the buffer to a file using the internal buffer filepath.
	returns error if there is no internal filepath set.
	returns NULL_BUFFER, SAVE_FAILED and NO_FILENAME errors.
```

### fn void! Buffer.save_as(&self, String filepath)

```
	saves te contents of the buffer to a file using filepath.
	the internal buffer filepath name is set to filepath.
	returns error if there is no internal filepath set.
	returns NULL_BUFFER, SAVE_FAILED and NO_FILENAM errors.
```

### fn BufferData* Buffer.data(self) @inline @private

```
	private method
	@return `a pointer to the buffer data`
```

### fn usz Buffer.capacity(self)

```
	@return `the capacity of buffer`
```

### fn String Buffer.get_filepath(self)

```
	@return `the filepath that is set for this buffer`
```

### fn usz Buffer.len(&self) @dynamic

```
	@return `the length of buffer`
```

### fn String Buffer.str_view(self)

```
	@return `a string slice of buffer contents`
```

### fn ZString Buffer.zstr_view(&self)

```
	@return `a zstring pointer of buffer contents. buffer is modified with a 0 at the end`
```

### fn void Buffer.clear(self)

```
	clears the contents of the buffer, does not reallocate memory.
```

### fn void Buffer.chop(self, usz new_size)

```
	@require new_size <= self.len()
```

### macro usz Buffer.get_cursor(self)

```
	@return `index of cursor`
```

### macro usz Buffer.cursor_to_eof(&self)

```
	move cursor to end of buffer
	@return `index of cursor`
```

### macro usz Buffer.cursor_to_bof(&self)

```
	move cursor to beginning of buffer
	@return `index of cursor`
```

### fn usz Buffer.cursor_to(&self, usz index)

```
	@param index `position to try moving cursor`
	@return `index of cursor`
```

### fn usz Buffer.cursor_right(&self, usz n)

```
	try to move cursor right (towards end of buffer)
	@param n `number of characters to move`
	@return `index of cursor`
```

### fn usz Buffer.cursor_left(&self, usz n)

```
	try to move cursor left (towards beginning of buffer)
	@param n `number of characters to move`
	@return `index of cursor`
```

### fn usz Buffer.cursor_right_lines(&self, usz num_lines)

```
	tries to move cursor right (towards end of buffer) num_lines number of lines.
	@param num_lines `number of lines to move`
	@return `index of cursor`
```

### fn usz Buffer.cursor_to_bol(&self)

```
	move cursor to beginning of current line
	@return `index of cursor`
```

### fn usz Buffer.cursor_to_eol(&self)

```
	moves the internal cursor to the the end of the current line
	@return `index of cursor`
```

### fn usz Buffer.span(&self, Cset set = WHITE_SPACES)

```
	moves the internal cursor to the next character that is not a member of set.
	@return `index of cursor`
```

### fn usz Buffer.r_span(&self, Cset set = WHITE_SPACES)

```
	moves the internal cursor to the previous character that is not a member of set.
	@return `index of cursor`
```

### fn usz Buffer.brk(&self, Cset set = WHITE_SPACES)

```
	moves the internal cursor to the next character that is a member of set.
	@return `index of cursor`
```

### fn usz Buffer.r_brk(&self, Cset set = WHITE_SPACES)

```
	moves the internal cursor to the previous character that is a member of set.
	@return `index of cursor`
```

### fn char! Buffer.get_char(&self)

```
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `character at cursor index in buffer. cursor is advanced by 1`
```

### fn char! Buffer.peek_char_at(&self, usz index)

```
	@return! BufferError.NULL_BUFFER, BufferError.INDEX_OUT_OF_RANGE
	@return `character at cursor index in buffer.`
```

### fn String! Buffer.get_word(&self, Cset set = WHITE_SPACES)

```
	gets the word under the cursor
	@param set `the character set to use to determine word separators, default WHITE_SPACES`
	@return! BufferError.NULL_BUFFER, BufferError.EOF, BufferError.NO_WORD
	@return `string slice containing the word`
```

### fn String! Buffer.get_line(&self, bool entire_line = true)

```
	@param entire_line `if true, finds the beginning and end of line at cursor, if false, beginning of line is starting cursor index`
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `string slice of entire line at cursor index, cursor is advanced to end of current line`
```

### macro String! Buffer.get_cursor_line(&self)

```
	wrapper for get_line with parameter for entire_line set to false.
```

### fn String! Buffer.get_line_from(&self, usz start)

```
	cursor independent method to get the string slice of a line
	@param start `index that determines beginning of line to retreive`
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `string slice of line starting at start`
```

### fn usz! Buffer.find_next(&self, String needle, bool case_sensitive = true)

```
	@param needle `string to search`
	@param case_sensitive `search is case_sensitive if true`
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `index in buffer where needle is found, cursor is advanced to end of found data`
```

### macro usz! Buffer.ifind_next(&self, String needle)

```
	wrapper around find_next with case_sensitive set to false
```

### fn usz! Buffer.find(&self, String needle, usz start_from = 0, bool case_sensitive = true)

```
	@param needle `the string to search for in the buffer`
	@param start_from `the index in buffer from which to begin searching`
	@param case_sensitive `if true, search is case sensitive, default true`
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `index if needle is found in buffer`
```

### macro usz! Buffer.ifind(&self, String needle, usz start_from = 0)

```
	wrapper around find method with case sensitive set to false
```

### macro void Buffer.append(&self, value)

```
	general purpose append macro
	recognizes the types of string, char, dstring, char32, buffer
```

### macro void Buffer.append_buffer(&self, Buffer buffer)

```
	general purpose append macro
	recognizes the types of string, char, dstring, char32, buffer
```

### macro void Buffer.append_chars(&self, String str)

```
	general purpose append macro
	recognizes the types of string, char, dstring, char32, buffer
```

### macro void Buffer.append_char(&self, char c)

```
	general purpose append macro
	recognizes the types of string, char, dstring, char32, buffer
```

### macro void Buffer.append_string(&self, DString str)

```
	general purpose append macro
	recognizes the types of string, char, dstring, char32, buffer
```

### macro usz Buffer.append_char32(&self, Char32 c)

```
	@require c <= 0x10ffff
```

### macro usz Buffer.append_utf32(&self, Char32[] chars)

```
	@require c <= 0x10ffff
```

### fn void Buffer.appendf(&self, String format, args...)

```
	appends a formatted string
	@param format `formatted string in the style of printf`
	@param args `varargs for formatted string`
```

### fn void Buffer.insertf(&self, usz index, String format, args...)

```
	inserts a formatted string
	@param index `location in buffer to insert`
	@param format `the formatted string in the style of printf`
	@param args `varargs for formatted string`
```

### fn void Buffer.append_repeat(&self, char c, usz times)

```
	repeatedly appends a sincgle character source.
	@param c `the character to append`
	@param times `the number of times to append c`
```

### fn usz! Buffer.write(&self, char[] buffer) @dynamic

```
	For OutStream interface
	appends a character slice into the buffer
	@param buffer `the slice to write into the buffer`
	@return `the length of characters written`
```

### fn void! Buffer.write_byte(&self, char c) @dynamic

```
	appends a singel byte into the buffer
	@param c `the character to append`
```

### fn void Buffer.set(self, usz index, char c)

```
	overwrites a character at index. does not change the size of buffer
	@param index `index of character to overwrite`
	@param c `the new character to insert at index`
	@require index < self.len()
```

### fn usz! Buffer.read_from_stream(&self, InStream reader)

```
	InStream reader for buffer. Data is appended to buffer
	@param reader `the InStream reader source`
	@return `number of bytes read from reader`
```

### macro void Buffer.insert(&self, usz index, value)

```
	general purpose insert macro
	recognizes the types string, char, dstring, buffer
	@param index `location in buffer to insert data`
	@param value `the value to insert at index`
```

### fn void Buffer.insert_buffer(&self, usz index, Buffer buffer)

```
	inserts a buffer object into the buffer.
	@param index `location in buffer to insert dest buffer`
	@param buffer `the dest buffer to insert at index`
```

### fn void Buffer.insert_chars(&self, usz index, String s)

```
	@param index `position in buffer to insert`
	@param s `the string slice to insert into buffer`
	@require index <= self.len()
```

### fn void Buffer.insert_string(&self, usz index, DString str)

```
	@param index `position in buffer to insert`
	@param str `the dynamic string to insert into buffer`
	@require index <= self.len()
```

### fn void Buffer.insert_char(&self, usz index, char c)

```
 	@param index `position in buffer to insert`
	@param c `the character to insert into buffer`
	@require index <= self.len()
```

### fn usz Buffer.insert_char32(&self, usz index, Char32 c)

```
	@param index `position in buffer to insert`
	@param c `the Char32 to insert into buffer`
	@require index <= self.len()
```

### fn usz Buffer.insert_utf32(&self, usz index, Char32[] chars)

```
	@param index `position in buffer to insert`
	@param chars `the Char32[] to insert into buffer`	
	@require index <= self.len()
```

### fn String! Buffer.next_token(&self, Cset set = DELIMITERS)

```
	uses internal cursor to tokenize the contents of the buffer
	returns a string slice for each token found.
	returns EOF error when there are no more tokens.
	@param set `a Cset of delimiters to use for isolating tokens.`
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `a string of found token`
```

### fn String! Buffer.peek_token(&self, Cset set = DELIMITERS)

```
	uses internal cursor to peek at the current token. does not advance the cursor
	returns a string slice for token found.
	returns EOF error when there are no more tokens.
	@param set `a Cset of delimiters to use for isolating tokens.`
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `a string of found token`
```

### fn void Buffer.delete(&self, usz start, usz len = 1)

```
	delete a number of bytes from the buffer
	@param start `location to start deleting`
	@param len `the number of bytes to delete, debault is 1`
	@require start < self.len()
	@require start + len <= self.len()
```

### fn void Buffer.replace_string(&self, String needle, String replacement)

```
	string replacement in buffer
	@param needle `the string to search for`
	@param replacement `the string used to replace, if needle is found`
```

### macro bool char_in_cset(char c, Cset set)

```
	checks to see if a character is in a character set
	@param c `the character to check for`
	@param set `the Cset in which to search for this character`
	@return `true if found, false if not found`
```

### fn void Buffer.trim(&self, Cset set = WHITE_SPACES)

```
	remove white spaces from start and end buffer
```

### fn void Buffer.delete_range(&self, usz start, usz end)

```
	like delete, but uses a range of start, end rather than start, len.
	@param start `location to start deleting`
	@param end `location to end deleting`
	@require start < self.len()
	@require end < self.len()
	@require end >= start "End must be same or equal to the start"
```

### fn void Buffer.replace_chars(self, char ch, char replacement)

```
	replaces every instance of char ch with char replacement
```

### fn void! Buffer.sub_buffer(&self, usz start_index, usz len, Buffer* dest)

```
	extracts a sub buffer from the buffer, copies it to dest buffer.
	@param start_index `location to start extraction`
	@param len `the number of bytes to copy`
	@param dest `a pointer to the dest buffer to copy data`
	@return! BufferError.NULL_BUFFER, BufferError.OPERATION_FAILED, BufferError.INDEX_OUT_OF_RANGE
```

### fn Buffer Buffer.new_sub_buffer(self, usz start_index, usz len, Allocator allocator = allocator::heap())

```
	like sub_buffer, but creates a new buffer
	@param start_index `location to start extraction`
	@param len `the number of bytes to copy`
	@param allocator `allocator to use, default allocator::heap()`
	@return `a new allocated Buffer`
```

### fn void! Buffer.sub_string(&self, usz start_index, usz len, DString* dest)

```
	extracts a sub string from the buffer, copies it to dest DString.
	@param start_index `location to start extraction`
	@param len `the number of bytes to copy`
	@param dest `a pointer to the dest dstring to copy data`
	@return! BufferError.NULL_BUFFER, BufferError.OPERATION_FAILED, BufferError.INDEX_OUT_OF_RANGE
```

### fn DString Buffer.new_sub_string(self, usz start_index, usz len, Allocator allocator = allocator::heap())

```
	like sub_string, but creates a new dstring
	@param start_index `location to start extraction`
	@param len `the number of bytes to copy`
	@param allocator `allocator to use, default allocator::heap()`
	@return `a new allocated dstring`
```

### fn Buffer Buffer.copy(self, Allocator allocator = null)

```
	dublicates a buffer. a null is returned if the self buffer is null.
	@param allocator `allocator to use. will use allocator::heap is none is passed.`
	@return `a new buffer object.`
```

### fn Buffer Buffer.temp_copy(&self) => self.copy(allocator::temp());

```
	dublicates a buffer. will use the temp allocator.
	@return `a new buffer object.`
```

### fn ZString Buffer.copy_zstr(self, Allocator allocator = allocator::heap())

```
	will create a ZString object from the contents of the buffer
	@param allocator `default allocator::heap()`
	@return `a ZString object`
```

### fn String Buffer.copy_str(self, Allocator allocator = allocator::heap())

```
	will create a String object from the contents of the buffer
	@param allocator `default allocator::heap()`
	@return `a String object`
```

### fn String Buffer.temp_copy_str(self) => self.copy_str(allocator::temp()) @inline;

```
	same as copy_str, but will use the temp allocator.
	@return `a String object`
```

### fn Char32[] Buffer.copy_utf32(&self, Allocator allocator = allocator::heap())

```
	will create an array of Char32[] from the contents of the buffer
	@param allocator `default is allocator::heap()`
```

### macro bool Buffer.iequals(self, Buffer other_buffer)

```
	compares to buffers for equality, case insensitive.
	@param other_buffer `the buffer to compare`
	@return `true if equal`
```

### fn bool Buffer.equals(self, Buffer other_buffer, bool case_sensitive = true)

```
	compares two buffers for equality, default case sensitive
	@param other_buffer `the buffer to compare`
	@param case_sensitive `true is compare is case sensitive`
	@return `true if equal`
```

### fn bool Buffer.less(self, Buffer other_buffer)

```
	compares two buffers
	@param other_buffer `the buffer to compare`
	@return `true if buffer is less than other_buffer`
```

### fn bool Buffer.is_eof(self)

```
	@return `true if cursor is at EOF`
```

