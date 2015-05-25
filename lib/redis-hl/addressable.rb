module RedisHL
  module Addressable
    def get(address)
      raise Unimplemented
    end

    def [](address)
      get(address)
    end

    def set(address, value)
      raise Unimplemented
    end

    def []=(address, value)
      set(address, value)
    end

    def mget(*addresses)
      raise Unimplemented
    end

    def mset(*addressesvalues)
      raise Unimplemented
    end

    def del(address)
      raise Unimplemented
    end

    def mdel(*addresses)
      raise Unimplemented
    end
  end
end
