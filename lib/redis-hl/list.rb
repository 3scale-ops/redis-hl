module RedisHL
  class List < Collection
    include Indexable

    supported_types :simplekey

    def initialize(key, parent:)
      super(:list, key, parent: parent)
    end

    # Redis' lists don't implement the scan interface, so we have to
    def scan(cursor, config)
      # we have to do this manually here
      sleep config[:pause]
      batch = config[:batch]

      keys = storage.lrange key, cursor, cursor + batch
      cursor = if keys.size < batch
                 '0'.freeze
               else
                 cursor + batch
               end

      # emulate the match feature by filtering here
      match = config[:match]
      filter_keys(keys, match) if match

      return cursor, keys
    end

    # O(1) implementations not relying on Enumerable
    def count
      storage.llen key
    end
    alias_method :size, :count
    alias_method :length, :count

    def index(idx)
      storage.lindex key, idx
    end
    #alias_method :get, :index

    def lset(index, value)
      storage.lset key, index, value
    end

    def lmget(index, len)
      storage.lrange key, index, index + len - 1
    end

    def range(start, stop)
      storage.lrange key, start, stop
    end

    def push(*values)
      storage.rpush key, *values
    end
    alias_method :<<, :push
    alias_method :mset, :push
    alias_method :set, :push

    def pop
      storage.rpop key
    end

    def shift
      storage.lpop key
    end

    def unshift(*values)
      storage.lpush key, *values
    end

    def del(key, count=1)
      storage.lrem self.key, count, key
    end

    def trim_fast(range_start, range_end)
      storage.ltrim key, range_start, range_end
    end

    def slice!(index, len=1, batch: self.batch)
      trim(index, index + len)
    end

    def trim(range_start, range_end, batch: self.batch)
      trim_list_left(range_start, batch: batch)
      trim_list_right(range_end, batch: batch)
    end

    #def naked_include?(key)
    #  find(Configuration.new(build_key: false)) do |x|
    #    x == key
    #  end
    #end

    def get(key)
      naked_has_key?(key)
    end

    def mget(*keys)
      keys = keys.dup
      each_naked.find_all do |x|
        keys.delete x if keys.include? x
      end
    end

    unwrap_single_key :del
    command_get :get, :mget, :pop, :shift
    #command :get, :mget, :pop, :shift do
    #  wrap { |*keys, **_opts| keys.map { |k| create k } }
    #end
    command :set, :mset, :push, :unshift do
      unwrap { |*keys| keys.map(&:key) }
    end

    command :lset do
      unwrap do |index, key|
        [index, key.key]
      end
    end

    private

    def filter_keys(keys, match)
      re = Regexp.new match
      keys.select! do |k|
        re.match(k)
      end
    end

    def trim_list_left(range_start, batch: self.batch)
      rs = 0
      loop do
        rs += batch
        rs = range_start if rs > range_start
        storage.ltrim key, rs, -1
        break if rs == range_start
        sleep pause
      end
    end

    def trim_list_right(range_end, batch: self.batch)
      re = storage.llen key
      loop do
        re -= batch
        re = range_end if re < range_end
        storage.ltrim key, 0, re
        break if re == range_end
        sleep pause
      end
    end
  end
end
