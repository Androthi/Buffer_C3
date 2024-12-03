# Auto Document Generator Test

## fn Buffer Buffer.new_init(&self, usz capacity = DEFAULT_CAPACITY, Allocator allocator = allocator::heap())

 Allocate memory for a new Buffer object. Panics if allocation fails
 @require !self.data() "Buffer already initialized"
 @param capacity `desired capacity for buffer, default = DEFAULT_CAPACITY`
 @param allocator `the allocator to use`
 @return `the allocated Buffer object`

## fn Buffer Buffer.temp_init(&self, usz capacity = DEFAULT_CAPACITY)

 @require !self.data() "Buffer already initialized"

## fn void Buffer.chop(self, usz new_size)

 @require new_size <= self.len()

