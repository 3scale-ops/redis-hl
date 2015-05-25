module RedisHL
  class ScoreKey < KeyValue
    def initialize(key, **options)
      super
      @type = :scorekey
    end
  end
end
