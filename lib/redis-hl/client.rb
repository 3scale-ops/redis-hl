module RedisHL
  class Client
    attr_reader :storage, :root
    attr_reader :config

    def initialize(redis = ::Redis.new, config: nil)
      @storage = redis
      @config = config || Configuration.new
      @root = Root.new(self)
    end

    def info
      Info.new storage
    end

    class Info
      attr_reader :info

      def initialize(storage)
        @info = storage.info
        @db = storage.client.db
      end

      def version
        @info['version']
      end

      def memory
        [
          'used_memory',
          'used_memory_human',
          'used_memory_rss',
          'used_memory_peak',
          'used_memory_peak_human',
          'used_memory_lua',
          'mem_fragmentation_ratio',
          'mem_allocator',
        ].inject({}) do |acc, e|
          acc[e] = info[e]
          acc
        end
      end

      def keys(i = nil)
        db(i)['keys']
      end

      def expires(i = nil)
        db(i)['expires']
      end

      def avg_ttl(i = nil)
        db(i)['avg_ttl']
      end

      def db(i = nil)
        i ||= @db
        if dbi = info.fetch("db#{i}", nil)
          dbi.split(',').map do |vars|
            vars.split '='
          end.inject({}) do |acc, (k, v)|
            acc[k] = v
            acc
          end
        end
      end

    end
  end
end
