module RedisHL
  Error = Class.new StandardError
  Unimplemented = Class.new Error
  TypeError = Class.new Error
  UnknownKeyType = Class.new TypeError
  UnsupportedKeyType = Class.new TypeError
end
