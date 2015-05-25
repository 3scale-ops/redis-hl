module RedisHL
  class Root < Collection
    include Addressable

    attr_reader :client

    supported_types :keyvalue, :string, :list, :hash, :set, :zset

    def initialize(client)
      super(:root, nil, parent: nil)
      @client = client
    end

    def shortname
      "Root"
    end

    # REDIS COLLECTION INTERFACE IMPLEMENTATION

    # scan for the root Redis collection
    def scan(cursor, config)
      storage.scan cursor, match: config[:match], count: config[:batch]
    end

    # type of a specified key -- in the Root collection we must
    # always ask Redis because we might have normal key-values
    # or collections
    def typeof(key)
      storage.type(key).to_sym
    end

    def has_key?(key)
      storage.exists key
    end

    def ttl(key)
      storage.pttl key
    end

    def setex(key, ttl, value)
      storage.setex key, ttl, value
    end

    def incr(key)
      storage.incr key
    end

    def incrby(key, incr)
      if incr.is_a? Float
        incrbyfloat key, incr
      else
        storage.incrby key, incr
      end
    end

    def incrbyfloat(key, value)
      storage.incrbyfloat key, value
    end

    # Addressable implementation

    def mget(*keys)
      storage.mget keys
    end

    def mset(*keyvalues)
      storage.mset keyvalues
    end

    def get(key)
      storage.get key
    end

    # normal 'set' cannot be impl'ed here, because parent is self, and also
    # because there is a command for setting here a key...
    # so basically set in collections should only be used to add/mod keys.
    # XXX add save for all keys, it also makes more sense with delete!
    def set(key, value)
      storage.set key, value
    end

    def del(key)
      storage.del self.key, key
    end

    def mdel(*keys)
      storage.del self.key, keys
    end

    unwrap_single_key :has_key?, :ttl, :del
    unwrap_keys :mdel
    wrap_value_unwrap_single_key :setex, :incr, :incrby, :incrbyfloat
    command_get :get, :mget
    command_set :set, :mset
  end

end
