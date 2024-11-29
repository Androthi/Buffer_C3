# Buffer module for C3
    this is a general purpose prototyping buffer. contains methods for adding and deleting data into the buffer, methods for tokenizing,
    file i/o, plans include adding methods for scanning, search/replace, various test-editing style functions. 

## WIP
    this is work in progress
    
## implemented functions

* new
* temp_new
* new_file
* temp_file
  
## implemented macros

* append
* insert
* append_file
* append_char
* append_chars
* append_char32
* append_utf32
* append_string
* append_buffer
* iequals

## implemented methods

* new_init
* temp_init
* open_file
* free
* reserve
* adjust_for_insert
* save
* save_as
* data
* capacity
* get_filepath
* set_filepath
* len
* str_view
* zstr_view
* clear
* chop
* set
* free
* appendf
* append_repeat
* write
* write_byte
* read_from_stream
* insertf
* insert_buffer
* insert_file
* insert_char
* insert_chars
* insert_string
* insert_char32
* insert_utf32
* delete
* delete_range
* copy
* temp_copy
* copy_zstr
* temp_copy_str
* copy_utf32
* equals
* less
* replace_chars
* sub_buffer
* new_sub_buffer
* sub_string
* new_sub_string
* trim
* char_in_cset
* cursor_to
* peek_token
* next_token