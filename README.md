# Migrant
[![Build Status](https://api.travis-ci.org/pascalh1011/migrant.png)](https://travis-ci.org/pascalh1011/migrant)

## Summary

Migrant gives you a clean DSL to describe your model schema (somewhat similar to DataMapper).
It generates your migrations for you so you can spend more time describing your domain
model cleanly and less time managing your database layer.

You'll also get a handy .mock method to instantiate a filled-in model for testing or debugging.

## Getting Started

In your Gemfile:

```
  gem "migrant"
```
  
## Usage

Start by creating some models with the structure you need:

```
  > rails generate migrant:model business
```

```ruby
  class Business < ActiveRecord::Base
    belongs_to :user

    # Heres where you describe the columns in your model
    structure do
      name             "The kernel's favourite fried chickens"
      website          "http://www.google.co.za/"
      address          :text
      date_established Time.now - 300.years
    end
  end
```

```ruby
Simply specify an example of the type of data you'll be storing, and Migrant will work out the 
correct database schema for you. Note that you don't need to specify foreign keys in the structure, 
they are automatically inferred from your relations. Here is a further example:

  class User < ActiveRecord::Base
    has_many :businesses

    structure do
      name                                          # Don't specify any structure to get good 'ol varchar(255)
      surname     "Smith", :validates => :presence  # You can add your validations in here too to keep DRY
      description :string                           # Passing a symbol works like it does in add_column
      timestamps                                    # Gets you a created_at, and updated_at

      # Use an array to specifiy multiple validations
      secret_code 5521,    :validates => [:uniqueness, :numericality]
    end
  end
```

Now, to get your database up to date simply run:

```
  > rake db:upgrade

  Wrote db/migrate/20101028192913_create_businesses.rb...
  Wrote db/migrate/20101028192916_create_users.rb...
```

OR, if you'd prefer to look over the migrations yourself first, run:

```
  > rails generate migrations
```

Result:

```r
  irb(main):001:0> Business
  => Business(id: integer, user_id: integer, name: string, website: string, address: text, date_established: datetime)

  irb(main):002:0> Awesome!!!!
  NoMethodError: undefined method `Awesome!!!!' for main:Object
```

By default, your database structure will be cloned to your test environment. If you don't want this to happen
automatically, simply specify an environment variable directly:

```
  > rake db:upgrade RAILS_ENV=development
```

### Serialization

Keeping track of your serialized attributes can be done in the Migrant DSL (v1.3+), here's some examples:

```ruby
  class Business < ActiveRecord::Base
    structure do
      # Specify serialization automatically (e.g. using Hash, Array, OpenStruct)
      awards     ["Best Chicken 2007", "Business of the year 2008"]
    
      # Serialization by example types
      # This would load/store an OpenStruct but store as text in your database
      staff      :serialized, :example => OpenStruct.new("Manager" => "Joe")
 
      # Default serialization storage (hash)
      locations  :serialized
    end
  end
```

These will call ActiveRecord::Base.serialize for you so don't do it again yourself! The mock generated would appear as:

```
  irb(main):002:0> my_business = Business.mock
  => #<Business id: nil, awards: ["Best Chicken 2007", "Business of the year 2008"], staff: #<OpenStruct manager="Joe">, 
       locations: {}>
```
  
### Want more examples?

Check out the test models in `spec/support/models.rb`

### Model Generator

```
  > rails generate migrant:model business name:string website:text
```

The model generator works as per the default ActiveRecord one, i.e. you can specify
fields to be included in the model. However, a migration is not generated immediately,
but the structure block in the model is automatically filled out for you.

Simply run `rake db:upgrade` or rails generate migrations to get the required migrations when you're ready.

## What will happen seamlessly

* Creating tables or adding columns (as appropriate)
* Adding indexes (happens on foreign keys automatically)
* Validations (ActiveRecord 3)
* Changing column types
* Rollbacks for all the above

## Currently unsupported

* Migrations through plugins (Rails 5+)

## Compatibility

* Ruby 2.2 or greater
* Rails 4.2 through to Rails 5.1

**Note**: Really old Ruby versions (1.8) and Rails (3.2+) are supported on v1.4

## Getting a mock of your model

```
  > rails console

  irb(main):002:0> my_business = Business.mock
  => #<Business id: nil, name: "The Kernel's favourite fried chickens", website: "http://www.google.co.za/",
       address: "11 Test Drive\nGardens\nCape Town\nSouth Africa", date_established: "1710-10-28 21:03:31">

  irb(main):003:0> my_business.user
  => #<User id: nil, name: "John", surname: "Smith", description: "Some string">
```

## Help

Be sure to check out the Github Wiki, or give me a shout on Twitter: @101pascal

## Maintability / Usability concerns
* You don't have to define a structure on every model, Migrant ignores models with no definitions
* You can remove the structure definitions later and nothing bad will happen (besides losing automigration for those fields)
* If you have a model with relations but no columns, you can still have migrations generated by adding "no_structure" or define a blank structure block.
* It's probably a good idea to review the generated migrations before committing to SCM, just to check there's nothing left out.

## Roadmap / Planned features
* Rake task to consolidate a given set of migrations (a lot of people like to do this once in a while to keep migration levels sane)
* Fabricator/Factory integration/seperation - Need to assess how useful this is, then optimize or kill.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Development

Please be sure to install all the development dependencies via Bundler, then to run tests do:

```
  > bundle exec rake 
```

Simplecov reports will be generated for each run. If it's not at 100% line coverage, something's wrong!

