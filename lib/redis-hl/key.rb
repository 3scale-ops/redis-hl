module RedisHL
  class Key
    module RootOps
      def self.add(on)
        instance_methods.each do |m|
          instance_method(m).bind(on)
        end
      end

      def expire(millisecs)
        storage.pexpire key, millisecs
      end

      def expire_at(timestamp)
        storage.expireat key, timestamp
      end

      def ttl
        storage.pttl key
      end
    end

    include Comparable

    attr_reader :key, :type, :parent

    def initialize(type, key, parent:)
      @type = type.to_sym
      @key = key
      @status = :unknown
      reparent(parent)
    end

    def reparent(parent)
      if @type == :root
        @parent = self
        @root = self
      else
        @parent = parent
        @root = if parent
                  p = self
                  # @root = @parent.root ?
                  loop do
                    break p if !p || p.type == :root
                    p = p.parent
                  end
                end

        add_ops
      end
    end

    def client
      @root.client
    end

    def storage
      client.storage
    end

    # default sorting by key
    def <=>(o)
      key <=> o.key
    end

    # keys are not collections by default
    def collection?
      false
    end

    def classname
      self.class.name.split(':').last
    end

    def shortname
      %[#{classname}: #{key} (#{@status})]
    end

    def inspect
      "#<#{shortname} [#{parent.shortname}]>"
    end

    def load!
      parent.get self
    end

    def save!
      parent.set self
    end

    def delete!
      parent.del self
    end

    def stored?
      parent.has_key? self
    end

    private

    def add_ops
      # in case this Key is part of the root of Redis add methods
      # supported by Redis only in the root.
      if parent && parent != self
        if parent.type == :root
          singleton_class.include RootOps
        elsif singleton_class.ancestors.include? RootOps
          # XXX uninclude RootOps!
        end
      end
    end
  end
end
