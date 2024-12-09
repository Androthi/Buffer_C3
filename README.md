# Buffer module for C3

    this is a general purpose prototyping buffer. contains methods for adding and deleting data into the buffer, methods for tokenizing,
    file i/o, plans include adding methods for scanning, search/replace, various test-editing style functions.
    all insertion methods will resize the buffer as needed.

## WIP

    this is work in progress
    
## memory allocation/free methods

    these functions can be used to initialize memory for new buffer objects.
    specific allocators can be used if desired. the xxx_file versions attempt
    to load the file 'filepath' into the buffer. if the file doesn't exist,
    an empty buffer is initialized.

### fn Buffer new(usz capacity = DEFAULT_CAPACITY, Allocator allocator = allocator::heap())

### fn Buffer temp_new(usz capacity = DEFAULT_CAPACITY) => new(capacity, allocator::temp()) @inline;

### fn Buffer new_file(String filepath)

### fn Buffer temp_file(String filepath)
  
### fn Buffer Buffer.new_init(&self, usz capacity = DEFAULT_CAPACITY, Allocator allocator = allocator::heap())

    inialize memory for a new buffer object.

### fn Buffer Buffer.temp_init(&self, usz capacity = DEFAULT_CAPACITY)

    initalize temporary memory for a new buffer object.

### fn void Buffer.free(&self)

    release allocated memory for this object.

## utility/internal methods

### macro bool Buffer.iequals(self, Buffer other_buffer)

    does case insensitive compare of two buffers.

### macro bool char_in_cset(char c, Cset set)

    searches a character set (a distinct String) for char c.
    returns true if the character is in the set.

### fn void Buffer.reserve(&self, usz addition) @private

    internal method to resize the buffer if needed.

### fn void Buffer.adjust_for_insert(&self, usz index, usz len) @private

    internal method to open len bytes at index in a buffer for a followup insertion.

### fn void! Buffer.save(&self)

    saves the contents of buffer to a file, at the previously set filepath

### fn void! Buffer.save_as(&self, String filepath)

    saves the contents of buffer to a file with new filepath, replasing any existing
    filepath.

### fn BufferData* Buffer.data(self) @inline @private

    internal method for retreiving the memory of the buffer.

### fn usz Buffer.capacity(self)

    returns the buffer's current capacity.

### fn String Buffer.get_filepath(self)

    returns the buffer's currently set filepath.

### fn void Buffer.set_filepath(&self, String filepath)

    replaces the buffer's currently set filepath.

### fn usz Buffer.len(&self) @dynamic

    returns the buffer's currentl length.

### fn String Buffer.str_view(self)

    returns a string view of the entire buffer contents.

### fn ZString Buffer.zstr_view(&self)

    returns a zstring view of the entire buffer contents.

### fn Buffer Buffer.copy(self, Allocator allocator = null)

    will copy the contents of a buffer into a new allocated object.

### fn Buffer Buffer.temp_copy(&self) => self.copy(allocator::temp())

    will copy the contents of a buffer into a temp allocated object.

### fn String Buffer.copy_str(self, Allocator allocator = allocator::heap())

    will copy the contents of a buffer into a new allocated string.

### fn String Buffer.temp_copy_str(self) => self.copy_str(allocator::temp()) @inline

    will copy the contents of a buffer into a temp allocated string.

### fn Char32[] Buffer.copy_utf32(&self, Allocator allocator = allocator::heap())

    will copy the contents of buffer into a new allocated Char32[]

### fn bool Buffer.equals(self, Buffer other_buffer, bool case_sensitive = true)

    returns true if other_buffer has the same contents as the buffer.
    default compare is case sensitive.

### fn bool Buffer.less(self, Buffer other_buffer)

    returns true if the contents of other_buffer is less than the contents of the buffer.

### fn void Buffer.replace_chars(self, char ch, char replacement)

    replaces any occurance of char ch with replacement char.

### fn void! Buffer.sub_buffer(&self, usz start_index, usz len, Buffer* dest)

    creates a sub_buffer with specified index and len into a specified dest buffer.

### fn Buffer Buffer.new_sub_buffer(self, usz start_index, usz len, Allocator allocator = allocator::heap())

    creates a sub_buffer with specified index and len into a new allocated dest buffer.

### fn void! Buffer.sub_string(&self, usz start_index, usz len, DString* dest)

    creates a sub_string with specified indeex and len into a specified dest DString.

### fn DString Buffer.new_sub_string(self, usz start_index, usz len, Allocator allocator = allocator::heap())

    creates a sub_string with specified indeex and len into a new allocated DString.

## data insertion/removal methods

### macro void Buffer.append(&self, value)

    appends value at EOF of the buffer. resizing if needed.
    the macro supports various known types.

### macro void Buffer.insert(&self, usz index, value)

    inserts value at index of the buffer. resizing if needed.
    the macro supports various known types.

### macro void Buffer.append_file(&self, String filepath)

    tries to append the file filepath at EOF of the buffer.

### macro void Buffer.append_char(&self, char c)

    appends a single char at EOF of the buffer.

### macro void Buffer.append_chars(&self, String str)

    appends a slice of chars at EOF of buffer.

### macro usz Buffer.append_char32(&self, Char32 c)

    appends a single char32 at EOF of the buffer.

### macro usz Buffer.append_utf32(&self, Char32[] chars)

    appends a single utf32 at EOF of the buffer.

### macro void Buffer.append_string(&self, DString str)

    appends a dynamic string at EOF of buffer.

### macro void Buffer.append_buffer(&self, Buffer buffer)

    appends another buffer object at EOF of buffer.

### fn void Buffer.open_file(&self, String filepath)

    tries to open a file, filepath and set the contents of the buffer.
    this will replace existing content in the buffer.
    use append_file to keep the contents of the buffer.

### fn void Buffer.clear(self)

    sets the buffer's length to zero.

### fn void Buffer.chop(self, usz new_size)

    truncates the buffer to a new size.

### fn void Buffer.set(self, usz index, char c)

    sets a single character at index, or at EOF if index exceeds length.

### fn void Buffer.appendf(&self, String format, args...)

    appends a formatted string at EOF of buffer.

### fn void Buffer.insertf(&self, usz index, String format, args...)

    inserts a formatted string at index of buffer.

### fn void Buffer.append_repeat(&self, char c, usz times)

    repeatedly appends a single characther a number of times, at EOF of buffer.

### fn usz! Buffer.write(&self, char[] buffer) @dynamic

    required method of OutStream interface.
    writes the contents of a slice at EOF of buffer.

### fn void! Buffer.write_byte(&self, char c) @dynamic

    writes a single byte at EOF of buffer.

### fn usz! Buffer.read_from_stream(&self, InStream reader)

    writes a stream of data from an InStream reader at EOF of buffer.

### fn void Buffer.insert_buffer(&self, usz index, Buffer buffer)

    inserts a buffer object at index.

### fn void Buffer.insert_file(&self, usz index, String filepath)

    attempts to load a file and insert it at index of buffer.
    will not change the buffer's existing filepath unless it's empty.

### fn void Buffer.insert_chars(&self, usz index, String s)

    inserts a slice of chars at index of buffer.

### fn void Buffer.insert_char(&self, usz index, char c)

    inserts a single character at index of buffer.

### fn void Buffer.insert_string(&self, usz index, DString str)

    inserts a string at index of buffer.

### fn usz Buffer.insert_char32(&self, usz index, Char32 c)

    inserts a single char32 at index of buffer.

### fn usz Buffer.insert_utf32(&self, usz index, Char32[] chars)

    inserts a single utf32 at index of buffer.

### fn void Buffer.delete(&self, usz start, usz len = 1)

    delets len characters from starting index of start.
    data is moved to fill the gap.
    will ignore command if index is out of bounds.

### fn void Buffer.delete_range(&self, usz start, usz end)

    deletes a range of characters from start to end.
    data is moved to fill the gap.
    will ignore command if index is out of bounds.

### fn void Buffer.trim(&self, Cset set = WHITE_SPACES)

    removes leading and trailing white spaces from the buffer.
    a different character set can be provided for trimming criteria.

## tokenizing methods

### fn String! Buffer.peek_token(&self, Cset set = DELIMITERS)

    returns a string token, starting at the cursor position. does not advance the cursor position.
    a different character set can be provided to replace the default set used.
    will return excuse of EOF if the cursor is at EOF.

### fn String! Buffer.next_token(&self, Cset set = DELIMITERS)

    returns a string token, starting at the cursor position. advances the cursor position.
    a different character set can be provided to replace the default set used.
    will return excuse of EOF if the cursor is at EOF.

## cursor methods

### fn void Buffer.cursor_to(&self, usz index)

    moves the internal cursor to specified index. cursor is moved to EOF if index exceeds length.

### macro void Buffer.cursor_to_eof(&self)

    moves the internal cursor to end of buffer.

### macro void Buffer.cursor_to_bof(&self)

    moves the internal cursor to beginning of buffer.

### fn void Buffer.cursor_to_bol(&self)

    moves the internal cursor to the beginning of the current line.

### fn void Buffer.cursor_to_eol(&self)

    moves the internal cursor to the end of the current line.

### fn void Buffer.cursor_right(&self, usz n)

    moves the internal cursor towards end of buffer by n amount.

### fn void Buffer.cursor_left(&self, usz n)

    moves the internal cursor towards the beginning of the buffer by n amount.

### macro usz Buffer.get_cursor(self)

    returns the index of the cursor.

### fn usz Buffer.cursor_right_lines(&self, usz num_lines)

    tries to move the cursor right num_lines, returns the index.

### fn usz Buffer.span(&self, Cset set = WHITE_SPACES)

    advances the internal cursor to the next character that is not a member of set.
    returns the index of cursor.

### fn usz Buffer.brk(&self, Cset set = WHITE_SPACES)

    advances te internal cursor to the next character that is a member of set.
    returns the index of cursor.

### fn char! Buffer.get_char(&self)

    returns the character at the cursor index, advances cursor by 1.

### fn char! Buffer.peek_char_at(&self, usz index)

    returns the character at index.
    returns INDEX_OUT_OF_RANGE, NULL_BUFFER errors

### fn String Buffer.get_line(&self, bool entire_line = true)

    returns the line at the cursor index, advances cursor by 1 beyond the end of line.
    if entire_line is false, the line is taken from the current cursor position to end of line.
    if entire_line is true (default), the line is taken from beginning of line to end of line with
    the cursor as reference (cursor can be anywhere in a line).

### fn String! Buffer.get_line_from(&self, usz start)

    returns the line from a start index. Does not advance cursor.

### macro String! get_cursor_line(&self)

    returns the line starting from the cursor position, advances cursor by 1 beyond the end of line.

### fn usz! Buffer.find(&self, String needle, usz start_from = 0, bool case_sensitive = true)

    returns index of needle or EOF
    begins search in buffer from start_index
    ASCII strings only

### macro usz! Buffer.ifind(&self, String needle, usz start_from = 0)

    returns index of needle or EOF
    begins case insensitive search in buffer from start_index
    ASCII strings only

### fn usz! Buffer.find_next(&self, String needle, bool case_sensitive = true)

    returns index of needle or EOF
    begins case sensitive search using the internal cursor as starting index.
    the internal cursor is adjusted either at EOF or at the index of found needle.

### macro usz! Buffer.ifind(&self, String needle)

    returns index of needle or EOF
    begins case insensitive search in buffer from the internal cursor
    the internal cursor is adjusted either at EOF or at the index of found needle.
    ASCII strings only

### fn void Buffer.replace_string(&self, String needle, String replacement)

    if needle exists in the buffer, it is replaced by replacement.
    if the buffer is empty, needle is written to the buffer.