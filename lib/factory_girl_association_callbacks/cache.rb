module FactoryGirlAssociationCallbacks
  # A hash that keeps the evaluation's overrides updated as we update. Used to
  # tie the ignored attributes to the cache used in assocation callbacks.
  class Cache < Hash
    def initialize(evaluation)
      super()
      @evaluation = evaluation
      replace @evaluation.ignored_fields
    end

    def []=(n,v)
      if @evaluation.attributes.map(&:name).include?(n)
        @evaluation.overrides[n] = v if @evaluation.attributes.map(&:name).include?(n)
      end
      super
    end
  end
end
