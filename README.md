# Factory Girl Association Callbacks

Custom strategies for factory girl that add `before` and `after`
callbacks to association attributes. Helpful when attributes have values
that are dependent on each other.

See factory girls `GETTING_STARTED.md` for a description of a custom
strategy.

## Installation

Add a git submodule for this project to vendor:

    git submodule add https://github.com/ajh/factory_girl_association_callbacks.git vendor/factory_girl_association_callbacks

Then configure it in `spec/spec_helper.rb` like this:

    # after require 'factory_girl'

    # Replace default factory girl strategies
    require Rails.root.join('vendor/factory_girl_association_callbacks/lib/factory_girl_association_callbacks')
    FactoryGirlAssociationCallbacks::Strategy.register

# What do I mean by consistency?

When associations have attributes that are dependant on each other, for
example a User may have a Contact and a TimeZone. The Contact address\_state
should be consistent with the TimeZone value (like MA and EST).

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

Here's an example:

    association :user, factory: :user,
      before: -> (cache:, attrs:, instance:) { attrs[:name] = "Fake user for #{instance.name}"},
      after: -> (user, cache:, **_) { cache[:user_address_state] = user.address_state }

## after callback

The `after` callback is called after the association was created by its
factory. It is passed an argument and two keywords.

* the first argument is the association objec that was just built
* `cache` keyword is the same `cache` as above
* `instance` is the same as above. In the example below, it would be an
  Equipment instance, not an association instance like User or Facility.

Here's an example of a way to use these. This factory builds a User
keeping the Contact and Timezone consistent.

    factory :user do
      association :contact,
                  before: -> (cache:, attrs:, instance:) { attrs[:address_state] = cache[:address_state] if cache[:address_state] },
                  after: -> (contact, cache:, instance:) { cache[:address_state] ||= contact.address_state }
      association :time_zone,
                  before: -> (cache:, attrs:, instance:) { attrs[:zone] = TimeZone.zone_for_state(cache[:address_state]) if cache[:address_state] },
                  after: -> (time_zone, cache:, instance:) { cache[:address_state] ||= TimeZone.state_for_zone(time_zone.zone) }
    end

# Cache and ignored attributes

The cache gets initialized with the values of ignored attributes if they
are defined. When a value gets assigned to the cache, its corresponding
ignored attribute changes as well.

For example:

    factory :example do
      ignore { user nil }
      association :blah,
                  before: -> (cache, attrs) { ... }
    end

    FactoryGirl.build :example # before callback will see cache = {:user => nil}
    FactoryGirl.build :example, user: u # before callback will see cache = {:user => u}

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
