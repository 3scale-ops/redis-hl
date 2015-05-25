module RedisHL
  class Command
    def self.command(*names, on: nil, &blk)
      new(*names).tap { |o| o.instance_exec(&blk) }.send :define!, on || blk.binding.eval('self')
    end

    def initialize(*names)
      @method_names = names
      @unwrap = ->(*args) { args }
      @wrap = ->(res, **_origargs) { res }
    end

    def unwrap(&blk)
      @unwrap = blk
    end

    def wrap(&blk)
      @wrap = blk
    end

    def work(&blk)
      @work = blk
    end

    private

    def define!(on)
      wrap, work, unwrap = @wrap, @work, @unwrap
      @method_names.each do |mname|
        # method name for the original, low-level one
        naked_meth = "naked_#{mname}"

        if work
          on.send :define_method, naked_meth, work
        elsif on.method_defined?(mname)
          on.send :alias_method, naked_meth, mname
        else
          raise Error, "No original method defined for command #{mname}"
        end

        methodinfo = work || on.instance_method(mname)
        on.send :remove_method, mname rescue nil
        on.send :define_method, mname do |*args, **options|
        unwrapped_args = unwrap.call(*args)
        # ideally you'd take this test out of the method body
        res = if methodinfo.parameters.last.first[0..2] == 'key'
                send(naked_meth, *unwrapped_args, **options)
              else
                send(naked_meth, *unwrapped_args)
              end
        wrap.call(res, original: args)
        end
      end
    end

  end
end
