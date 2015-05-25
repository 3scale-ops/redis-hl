module RedisHL
  class ZSet < Collection
    supported_types :scorekey

    def initialize(key, parent:)
      super(:zset, key, parent: parent)
    end

    def scan(cursor, config)
      storage.zscan key, cursor, match: config[:match], count: config[:batch]
    end

    # O(1) implementations not relying on Enumerable
    def include?(key)
      has_key? key
    end

    def has_key?(key)
      storage.zrank(self.key, key) != nil
    end

    def count
      storage.zcard key
    end
    alias_method :size, :count
    alias_method :length, :count

    def count_by_score(min, max)
      storage.zcount key, min, max
    end

    def count_by_lex(min, max)
      storage.zlexcount key, min, max
    end

    # options :with_scores => boolean
    def index(idx, options = {})
      storage.zrange key, idx, idx, options
    end

    def rindex(idx, options = {})
      storage.zrevrange key, idx, idx, options
    end

    # options is :with_scores => boolean
    def range(start, stop, options = {})
      storage.zrange key, start, stop, options
    end

    # options is :with_scores => boolean
    def rrange(start, stop, options = {})
      storage.zrevrange key, start, stop, options
    end

    # options are :limit, receives array of offset and count
    # and :with_scores, received boolean
    # ie: limit: [0, 2], with_scores: true => first 2 starting at 0 index
    # with scores
    def range_by_score(min, max, options = {})
      storage.zrangebyscore key, min, max, options
    end

    def rrange_by_score(min, max, options = {})
      storage.zrevrangebyscore key, min, max, options
    end

    # receives :limit only
    def range_by_lex(min, max, options = {})
      storage.zrangebylex key, min, max, options
    end

    def rrange_by_lex(min, max, options = {})
      storage.zrevrangebylex key, min, max, options
    end

    def rank(key)
      storage.zrank self.key, key
    end

    def rrank(key)
      storage.zrevrank self.key, key
    end

    def get(key)
      storage.zscore self.key, key
    end
    alias_method :[], :get

    # no real MGET, not emulating since it'd be dangerous

    def set(key, score)
      storage.zadd self.key, score, key
    end
    alias_method :[]=, :set

    def mset(*scorekeys)
      storage.zadd self.key, scorekeys
    end
    alias_method :push, :mset
    alias_method :<<, :mset

    def del(key)
      storage.zrem self.key, key
    end

    def mdel(*keys)
      del keys
    end

    def del_by_rank(start, stop)
      storage.zrembyrank key, start, stop
    end

    def del_by_score(min, max)
      storage.zremrangebyscore key, min, max
    end

    def del_by_lex(min, max)
      storage.zremrangebylex key, min, max
    end

    # SET METHODS

    def union(dest, *keys)
      storage.zunionstore dest, keys.size, keys
    end

    def union!(key)
      storage.zunionstore self.key, 2, self.key, key
    end

    def inter(dest, *keys)
      storage.zinterstore dest, keys.size, keys
    end

    def inter!(key)
      storage.zinterstore self.key, 2, self.key, key
    end

    # save/delete a single hl key
    def save(key)
      set(key, key.value).tap do
        @status = :saved
      end
    end

    def delete(key)
      del(key).tap do
        @status = :deleted
      end
    end

    wrap_keys :index, :rindex, :range, :rrange, :range_by_score,
      :rrange_by_score, :range_by_lex, :rrange_by_lex
    unwrap_single_key :has_key?, :rank, :rrank, :set, :del,
      :union!, :inter!
    unwrap_keys :mdel, :union, :inter
    command :mset, :push do
      unwrap { |*keys| keys.map { |k| [k.value, k.key] }.flatten! }
    end
    command_get :get

  end
end
