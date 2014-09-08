module FactoryGirlAssociationCallbacks

  # Runs associations with before and after callbacks.
  #
  # Wishlist: It'd be nice to have access to the instance built by the factory
  # that defined the association so that it can be passed into the callbacks.
  # That would handle the use case of dependent attrs.
  class FactoryRunnerWithCallbacks
    def initialize(runner:, cache:, useful_evaluation:)
      @cache = cache
      @runner = deep_dup_runner runner
      @useful_evaluation = useful_evaluation
    end

    def name
      @runner.instance_variable_get "@name"
    end

    def overrides
      @runner.instance_variable_get "@overrides"
    end

    def run(*args, &block)
      before_proc = overrides.delete :before
      after_proc = overrides.delete :after

      before_proc.call cache: @cache, attrs: overrides, instance: @useful_evaluation.instance if before_proc

      @runner.run(*args, &block).tap {|obj|
        after_proc.call obj, cache: @cache, instance: @useful_evaluation.instance if after_proc
      }
    end

    private

    def deep_dup_runner(runner)
      r = runner.dup
      # wish we had deep_dup
      %w(overrides traits).each do |v|
        r.instance_variable_set \
          "@#{v}",
          runner.instance_variable_get("@#{v}").dup
      end

      r
    end
  end
end
