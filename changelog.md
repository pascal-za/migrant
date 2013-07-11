### 1.4.3

[full changelog](http://github.com/pascalh1011/migrant/compare/v1.4.0...v1.4.3)

* Bug Fixes
  * Name migrations correctly that only add one index
  * Now compatible with Rails 4.0

### 1.4.2

* Bug Fixes
  * Generate date fields by default when Date class is given to structure block

* Misc
  * Added timestamps to migrant:model generator by default

### 1.4.1 / 2013-03-16

[full changelog](http://github.com/pascalh1011/migrant/compare/v1.4.0...v1.4.1)

* Bug Fixes
  * Fix term-ansicolor not being detected as a dependency in some bundler versions
  * Signed with RubyGems OpenPGP (experimental)

### 1.4.0 / 2013-02-03

[full changelog](http://github.com/pascalh1011/migrant/compare/v1.3.2...v1.4.0)

* Features
  * Changes to the column default are now detected
  * Change migrations filenames are named using new default values (to avoid conflicts)
  * Remove official 1.8 support (still works but too much testing overhead for now)

* Bug fixes
  * Fixed associations failing to be added to the base model when using STI
  * Fix possible issue with PostgreSQL regenerating migrations if the range primitive is used

### 1.3.2 / 2012-03-08

[full changelog](http://github.com/pascalh1011/migrant/compare/v1.3.1...v1.3.2)

* Bug fixes
  * [CRITICAL] Specifying a belongs_to association in a model no longer automatically assumes a schema creation

### 1.3.1 / 2012-02-12

[full changelog](http://github.com/pascalh1011/migrant/compare/v1.3.0...v1.3.1)

* Features
  * Migrant now offers to generate migrations that would lose data in conversion (eg. text -> int), after warning the user.
  * Now on [Travis CI](http://travis-ci.org/#!/pascalh1011/migrant)! 

* Bug fixes
  * Disable schema cache for Rails >= 3.2.0.rc2. Mostly fixes issues with the tests, but peace of mind for Rails 3.2 nonetheless.
  * Fix filename tests not running on some systems

* Contributors
  * pascalh1011
  * L2G
