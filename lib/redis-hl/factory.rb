module RedisHL
  module Factory
    TYPE_TO_CLASS = {
      list:      List,
      set:       Set,
      zset:      ZSet,
      hash:      Hash,
      simplekey: SimpleKey,
      scorekey:  ScoreKey,
      string:    KeyValue,
      keyvalue:  KeyValue   # same as string, for convenience
    }.freeze

    def self.build(type, key, parent:)
      TYPE_TO_CLASS[type.to_sym].new(key, parent: parent)
    end
  end
end
