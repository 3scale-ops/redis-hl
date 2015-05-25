module RedisHL
  class KeyValue < Key
    attr_reader :value

    def initialize(key, **options)
      # we might be given key: [key, value] in some cases
      key, @value = key
      super(:string, key, **options)
    end

    def save!(value = self.value)
      @value = parent.set(self, value).tap do
        @status = :saved
      end
    end

    def load!
      # naked_get avoids creating a temporal key
      @value = parent.naked_get(self.key).tap do
        @status = :saved
      end
    end
    alias_method :value!, :load!

    def value=(value)
      @value = value.tap do
        @status = :dirty
      end
    end

    def saved_value=(value)
      @value = value.tap do
        @status = :saved
      end
    end

    def setex(ttl, value)
      @value = parent.setex(self, ttl, value).tap do
        @status = :saved
      end
    end

    def incrby(value)
      @value = parent.incrby(self, value).tap do
        @status = :saved
      end
    end

    def incr
      # some collections don't support incr :(
      @value = if parent.respond_to?(:incr)
        parent.incr self
      else
        parent.incrby self, 1
      end.tap do
        @status = :saved
      end
    end

    def shortname
      "#{super} => #{value}"
    end
  end
end
