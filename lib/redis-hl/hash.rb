module RedisHL
  class Hash < Collection
    include Addressable

    supported_types :keyvalue, :string

    def initialize(key, parent:)
      super(:hash, key, parent: parent)
    end

    def scan(cursor, config)
      storage.hscan key, cursor, match: config[:match], count: config[:batch]
    end

    def typeof(_key)
      :string # actually a KeyValue
    end

    # O(1) implementations not relying on Enumerable
    def count
      storage.hlen key
    end
    alias_method :size, :count
    alias_method :length, :count

    def include?(key)
      has_key?(key)
    end

    def has_key?(key)
      storage.hexists self.key, key
    end

    def get(key)
      storage.hget self.key, key
    end

    def set(key, value)
      storage.hset self.key, key, value
    end

    def mget(*keys)
      storage.hmget key, keys
    end

    def mset(*keyvalues)
      storage.hmset key, keyvalues
    end

    def del(key)
      storage.hdel self.key, key
    end

    def mdel(*keys)
      storage.hdel key, keys
    end

    def incrby(key, incr)
      if incr.is_a? Float
        incrbyfloat key, incr
      else
        storage.hincrby self.key, key, incr
      end
    end

    def incrbyfloat(key, incr)
      storage.hincrbyfloat self.key, key, incr
    end

    def incr(key)
      incrby key, 1
    end

    # very specific method
    def strlen(key)
      storage.hstrlen self.key, key
    end

    def keys
      storage.hkeys key
    end

    def values
      storage.hvals key
    end

    unwrap_single_key :has_key?, :incrby, :incrbyfloat, :del, :strlen
    unwrap_keys :mdel
    command_get :get, :mget
    command_set :set, :mset
  end
end
