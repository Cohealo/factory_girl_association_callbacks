module FactoryGirlAssociationCallbacks
  # extends FactoryGirl Evaluation to provide more control over factory execution
  class UsefulEvaluation
    def initialize(evaluation)
      @evaluation = evaluation
    end

    def name
      @evaluation \
        .instance_variable_get("@attribute_assigner") \
        .instance_variable_get("@build_class") \
        .to_s
    end

    def strategy_name
      s = @evaluation \
        .instance_variable_get("@attribute_assigner") \
        .instance_variable_get("@evaluator") \
        .instance_variable_get("@build_strategy")

      s.class.to_s.demodulize.underscore.to_sym
    end

    # return a hash of name => value for ignored values. Values are determined
    # from the factory defn of the ignored attribute or by an overridden value. A
    # overridden value has precedence.
    def ignored_fields
      fields = {}

      attributes.select {|a| a.instance_variable_get "@ignored"}.each do |a|
        fields[a.name] = a.instance_variable_get("@value")
      end
      overrides.each do |name, obj|
        fields.key? name or next
        fields[name] = obj
      end

      fields
    end

    # return overrides passed to factory
    def overrides
      @evaluation \
        .instance_variable_get("@attribute_assigner") \
        .instance_variable_get("@evaluator") \
        .instance_variable_get("@overrides")
    end

    def attributes
      @evaluation \
        .instance_variable_get("@attribute_assigner") \
        .instance_variable_get("@attribute_list") \
        .instance_variable_get("@attributes")
    end

    # return association definitions
    def associations
      attributes.select {|a| a.is_a? FactoryGirl::Attribute::Association }
    end

    # return a map of overrides to associations and its after proc. If an
    # association isn't overridden or doesn't have an after proc its not
    # included. The format looks like this:
    #
    #   {
    #     #<Obj1...> => [#<Proc...>],
    #     #<Obj2...> => [#<Proc...>],
    #   }
    def overridden_associations_with_after_procs
      procs_by_obj = {}

      overrides.each do |name, obj|
        a = associations.find {|assoc| assoc.name == name}
        a or next

        # @overrides is an array of hashes. I wonder if someday it'll just be a
        # hash?
        after_procs = a.instance_variable_get("@overrides").map do |hash|
          hash[:after]
        end.compact
        after_procs.any? or next

        procs_by_obj[obj] = after_procs
      end

      procs_by_obj
    end

    # returns this instance that is being built (or nil if it hasn't been
    # instantiated yet).
    def instance
      @evaluation \
        .instance_variable_get("@attribute_assigner") \
        .instance_variable_get("@evaluator") \
        .instance_variable_get("@instance") \
    end
  end
end
