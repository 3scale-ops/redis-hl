module RedisHL
  # a key with no value, such as those in lists or sets
  class SimpleKey < Key
    def initialize(key, **options)
      super(:simplekey, key, **options)
    end
  end
end
