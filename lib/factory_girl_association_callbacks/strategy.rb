require File.expand_path('../cache', __FILE__)
require File.expand_path('../factory_runner_with_callbacks', __FILE__)
require File.expand_path('../useful_evaluation', __FILE__)

module FactoryGirlAssociationCallbacks
  module Strategy

    # Replace default factory girl strategies with our own
    def self.register
      FactoryGirl.register_strategy(:attributes_for, CustomAttributesForStrategy)
      FactoryGirl.register_strategy(:build, CustomBuildStrategy)
      FactoryGirl.register_strategy(:build_stubbed, CustomStubStrategy)
      FactoryGirl.register_strategy(:create, CustomCreateStrategy)
      FactoryGirl.register_strategy(:null, CustomNullStrategy)
    end

    # Base class for strategies. Subclasses need to define the class variable
    # :association_strategy for the base implementations to work.
    class BaseStrategy
      # sub classes must define this
      class_attribute :association_strategy

      # a cache while the factory is executing
      attr_accessor :cache

      # the evaluation while can provide context
      attr_accessor :useful_evaluation

      def association(runner)
        FactoryRunnerWithCallbacks.new(runner: runner, cache: cache, useful_evaluation: useful_evaluation).run self.class.association_strategy
      end

      def result(evaluation)
        self.useful_evaluation = UsefulEvaluation.new evaluation
        @cache = Cache.new useful_evaluation

        # find associations with overrides. run after hooks on them.
        useful_evaluation.overridden_associations_with_after_procs.each { |obj, procs|
          procs.each {|p| p.call obj, cache: cache, instance: useful_evaluation.instance }
        }

        # sub classes should call evaluation.object or whatever after calling super
      end
    end

    class CustomCreateStrategy < BaseStrategy
      self.association_strategy = :create

      def result(evaluation)
        super

        evaluation.object.tap do |instance|
          evaluation.notify(:after_build, instance)
          evaluation.notify(:before_create, instance)
          evaluation.create(instance)
          evaluation.notify(:after_create, instance)
        end
      end
    end

    class CustomBuildStrategy < BaseStrategy
      self.association_strategy = :build

      def result(evaluation)
        super

        evaluation.object.tap do |instance|
          evaluation.notify(:after_build, instance)
        end
      end
    end

    class CustomAttributesForStrategy < BaseStrategy
      self.association_strategy = :null

      def result(evaluation)
        super
        evaluation.hash
      end
    end

    class CustomNullStrategy < BaseStrategy
      self.association_strategy = :null

      def result(evaluation)
        # nothing here
      end
    end

    class CustomStubStrategy < BaseStrategy
      self.association_strategy = :build_stubbed

      def result(evaluation)
        super
        evaluation.object.tap do |instance|
          FactoryGirl::Strategy::Stub.new.send \
            :stub_database_interaction_on_result,
            instance
          evaluation.notify(:after_stub, instance)
        end
      end
    end

  end
end
