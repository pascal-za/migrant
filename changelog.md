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
