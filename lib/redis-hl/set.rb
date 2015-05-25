module RedisHL
  class Set < Collection
    supported_types :simplekey

    def initialize(key, parent:)
      super(:set, key, parent: parent)
    end

    def scan(cursor, config)
      storage.sscan key, cursor, match: config[:match], count: config[:batch]
    end

    def has_key?(key)
      storage.sismember self.key, key
    end

    def count
      storage.scard key
    end
    alias_method :size, :count
    alias_method :length, :count

    def get(key)
      storage.sismember(self.key, key) && key
    end

    def mset(*values)
      storage.sadd key, values
    end
    alias_method :push, :mset
    alias_method :<<, :mset
    alias_method :set, :mset
    alias_method :add, :mset

    def pop(_count = 1)
      storage.spop key
    end

    def del(key)
      storage.srem self.key, key
    end

    def mdel(*keys)
      del keys
    end

    def rand(count = 1)
      storage.srandmember key, count
    end

    def union(o)
      storage.sunion key, o
    end
    alias_method :+, :union

    def inter(o)
      storage.sinter key, o
    end
    alias_method :*, :inter

    def diff(o)
      storage.sdiff key, o
    end
    alias_method :-, :diff

    def union!(key, o)
      storage.sunionstore self.key, key, o
    end

    def inter!(key, o)
      storage.sinterstore self.key, key, o
    end

    def diff!(key, o)
      storage.sdiffstore self.key, key, o
    end

    def move!(key, o)
      storage.smove self.key, o, key
    end

    wrap_unwrap_keys :union, :inter, :diff
    unwrap_single_key :has_key?, :rand, :pop, :del,
      :union!, :inter!
    unwrap_keys :mdel
    command_set :set, :mset, :push, :add
    command_get :get
  end
end
