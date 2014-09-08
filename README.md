# Factory Girl Association Callbacks

# What is this?

Its a set of custom strategies for factory girl. See factory girls
`GETTING_STARTED.md` for a description of a custom strategy.

These strategies add callbacks to association attributes which are
helpful to when attributes have values that are dependent on each other.

# What do I mean by consistency?

All associations should be consistent. For example when creating a booking,
its equipment and booking\_data should have facilities within the same
health system. Also delivery dates should make sense given the booking, etc.

# About the callbacks

Callbacks are added to association attributes. These are attributes
defined with factory girl's `association` method, like:

    association :user, factory: :user

Two callbacks are added, a `before` and an `after`.

## before callback

The `before` callback is called just before the association is built. It
is passed three keyword arguments, `cache`, `attrs` and `instance`.

* `cache` is a hash where state can be stored while the factory is
  running. Its state is shared between association calls.
* `attrs` is a hash that will be passed as overrides to the factory
  creating the association object.
* `instance` is the object the factory is building

## after callback

The `after` callback is called after the association was created by its
factory. It is passed an argument and two keywords.

* the first argument is the association objec that was just built
* `cache` keyword is the same `cache` as above
* `instance` is the same as above. In the example below, it would be an
  Equipment instance, not an association instance like User or Facility.

Here's an example of a way to use these. This factory builds a equipment
that has a user and a facility. Both of these should belong to the same
health system to be consistent.

    factory :equipment do
      association :user,
                  before: -> (cache:, attrs:, instance:) { attrs[:health_system] = cache[:health_system] if cache[:health_system] },
                  after: -> (u, cache:, instance:) { cache[:health_system] ||= u.health_system }
      association :facility,
                  before: -> (cache:, attrs:, instance:) { attrs[:health_system] = cache[:health_system] if cache[:health_system] },
                  after: -> (f, cache:, instance:) { cache[:health_system] ||= f.health_system }
    end

# Cache and ignored attributes

The cache gets initialized with the values of ignored attributes if they
are defined. When a value gets assigned to the cache, its corresponding
ignored attribute changes as well.

For example:

    factory :example do
      ignore { health_system nil }
      association :facility,
                  before: -> (cache, attrs) { ... }
    end

    FactoryGirl.build :example # before callback will see cache = {:health_system => nil}
    FactoryGirl.build :example, health_system: h # before callback will see cache = {:health_system => h}

# Notes on strategies

## Build

Should build unsaved associations. Associations should be consistent.
Nothing should hit the database.

Not all bidirectional associations are correctly setup due to limitations
of active record (`inverse_of` doesn't always work).

## Create

Should create persisted associations. Associations should be consistent.

## Build Stubbed

It mostly works like build. I don't know a way to stub `has_many`
associations, and there are a few other issues which can maybe be
ironed out. See the commented out specs.

## Attributes For

Seems to ignore associations altogether. If a model validates
presence of an association then this is a problem.
