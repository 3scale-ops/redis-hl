require 'set'

module RedisHL
  class Collection < Key
    COMPOSED_TYPES = Set.new([:root, :set, :zset, :list, :hash]).freeze

    include Enumerable
    include Command::Helpers

    attr_reader :key, :type

    def initialize(type, key, parent:)
      super(type, key, parent: parent)
    end

    def config
      client.config
    end

    # generic scan function, returns cursor, keys
    def scan(_cursor, _config)
      raise Unimplemented
    end

    # type of a specified key in this collection - must return a Symbol
    def typeof(_key)
      raise Unimplemented
    end

    # usually overwritten to O(1) implementations not relying on #each
    def has_key?(key)
      each_naked.find do |x|
        x == key
      end
    end
    unwrap_single_key :has_key?

    def include?(key)
      has_key?(key)
    end

    def each_naked(config: Configuration::NAKED)
      config.build_key = false
      each(config: config)
    end

    # each for collections
    # all collections must implement the scan interface because
    # that's the most restrictive interface and also models our need
    # to not hog the database
    #
    def each(config: nil, resumeinfo: nil, &blk)
      if blk.nil?
        e = to_enum(__method__, config: config, resumeinfo: resumeinfo)
        self.class.decorate_enum(e, config, resumeinfo)
        return e
      end
      config = config ? self.config.merge(config) : self.config
      resumeinfo ||= config[:resumeinfo]
      cursor = if resumeinfo
                 resumeinfo.reset! if resumeinfo.finished?
                 resumeinfo.cursor
               else
                 0
               end
      STDERR.puts "ITERATING WITH #{config}, #{resumeinfo}"
      build = config[:build_key]
      loop do
        cursor, keys = scan(cursor, config)
        resumeinfo.track cursor, keys.size if resumeinfo
        keys.each do |key|
          blk.call(represent_key(key, build))
        end
        break if cursor == '0'.freeze
      end
    end

    # collections are, well, collections
    def collection?
      true
    end

    # create a new key object attached to this collection
    def create(key, type = nil)
      type ||= typeof key
      raise UnknownKeyType if type.nil? || type == :none
      raise UnsupportedKeyType unless self.class.supported_types.include?(type)
      Factory.build(type, key, parent: self)
    end

    def self.supported_types(*types)
      return @supported_types ||= [] if types.empty?
      if types.size == 1
        define_method :typeof do |_|
          types.first
        end
      end
      @supported_types = types
    end

    private

    # this is a representation of an ALREADY existing key instance
    def represent_key(key, build)
      t = typeof key
      if COMPOSED_TYPES.include?(t.to_sym) || build
        create key, t
      else
        key
      end
    end

    def self.decorate_enum(e, config, resumeinfo)
      e.define_singleton_method :params do
        { config: config, resumeinfo: resumeinfo }
      end
      collection = self
      e.define_singleton_method :collection do
        collection # can't use self here, as it is evaluated under enumerator
      end
    end

    class ResumeInfo
      def initialize(cursor = 0)
        reset! cursor
      end

      def reset!(cursor = 0)
        @elements = []
        @cursors = [cursor]
      end

      def cursor
        @cursors.first
      end

      def track(c, elements)
        @elements << elements
        @cursors << c
      end

      def ack!(size)
        remaining = @elements[0] -= size
        while remaining <= 0
          @elements.shift
          @cursors.shift
          break if remaining == 0
          remaining = @elements[0] += remaining
        end
      end

      def finished?
        # note it is not 0, but '0'
        @cursors.first == '0'.freeze
      end

      def pending?
        !finished
      end
    end
  end
end
