module RedisHL
  class Command
    module Helpers
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def command(*meth, &blk)
          Command.command(*meth, &blk)
        end

        def wrap_keys(*meth)
          command(*meth) do
            wrap do |*keys, **_|
              keys.map do |k|
                create(k).tap do |wk|
                  wk.instance_variable_set('@status', :saved)
                end
              end
            end
          end
        end

        def unwrap_keys(*meth)
          command(*meth) do
            unwrap { |*keys| keys.map(&:key) }
          end
        end

        def wrap_unwrap_keys(*meth)
          command(*meth) do
            unwrap { |*keys| keys.map(&:key) }
            wrap do |*keys, **_|
              keys.map do |k|
                create(k).tap do |wk|
                  wk.instance_variable_set('@status', :saved)
                end
              end
            end
          end
        end

        def wrap_value_unwrap_single_key(*meth)
          command(*meth) do
            unwrap { |key, *args| [key.key, *args] }
            wrap do |res, original:|
              orig = original.first
              (orig.value = res).tap do
                orig.instance_variable_set('@status', :saved)
              end
            end
          end
        end

        def unwrap_single_key(*meth)
          command(*meth) do
            unwrap { |key, *args| [key.key, *args] }
          end
        end

        def command_get(*meth)
          command(*meth) do
            unwrap { |*keys| keys.map(&:key) }
            wrap do |*keys, original:|
              keys.flatten!
              original.zip keys do |orig, val|
                orig.saved_value = val if orig.respond_to?(:saved_value=)
              end
            keys.size > 1 ? keys : keys.first
            end
          end
        end

        def command_set(*meth)
          command(*meth) do
            unwrap { |*keyvalues|
              keyvalues.each_slice(2).map { |k, v| [k.key, v] }.flatten! }
          end
        end
      end
    end

  end
end
