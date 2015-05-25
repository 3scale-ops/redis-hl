module RedisHL
  Configuration = Struct.new(:match, :batch, :pause, :build_key, :resumeinfo) do
    DEFAULT_MATCH = nil
    DEFAULT_BATCH = 200
    DEFAULT_PAUSE = 0.05
    DEFAULT_BUILDKEY = true

    def initialize(*args, **opts)
      raise ArgumentError, "Max argument/options size is 5" if args.size > 5
      raise ArgumentError, "Max options size is 5" if opts.size > 5

      optarg = [opts.delete(:match), opts.delete(:batch), opts.delete(:pause), opts.delete(:build_key), opts.delete(:resumeinfo)]
      raise ArgumentError, "Unknown options in Configuration" unless opts.empty?

      optarg.each_with_index do |o, i|
        args[i].nil? && args[i] = o
      end

      super(*args)

      self.match     ||= DEFAULT_MATCH
      self.batch     ||= DEFAULT_BATCH
      self.pause     ||= DEFAULT_PAUSE
      self.build_key = DEFAULT_BUILDKEY if self.build_key.nil?
    end

    def merge(o)
      self.class.new(o[:match] || match, o[:batch] || batch,
                     o[:pause] || pause, o[:build_key].nil? ? build_key : o[:build_key])
    end
  end

  class Configuration
    NAKED = new(build_key: false)
  end
end
