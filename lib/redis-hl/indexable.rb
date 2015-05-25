module RedisHL
  module Indexable
    include Addressable

    def index(key)
      raise Unimplemented
    end

    def mget(index, len)
      raise Unimplemented
    end

    def mset(index, keyvals)
      raise Unimplemented
    end
  end
end
