# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{migrant}
  s.version = File.read('VERSION')

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pascal Houliston"]
  s.description = %q{Easier schema management for Rails that complements your domain model.}
  s.email = %q{101pascal@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")

  s.homepage = %q{http://github.com/pascalh1011/migrant}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{All the fun of ActiveRecord without writing your migrations, and with a dash of mocking.}

  s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
  s.add_development_dependency(%q<minitest>, ["~> 4.2"])
  s.add_development_dependency(%q<ansi>, [">= 0"])
  s.add_development_dependency(%q<turn>, [">= 0"])
  s.add_development_dependency(%q<sqlite3>, [">= 0"])
  s.add_development_dependency(%q<simplecov>, [">= 0"])
  s.add_development_dependency(%q<terminal-table>, [">= 0"])
  s.add_development_dependency(%q<rake>, [">= 0.8.7"])
  s.add_development_dependency(%q<simplecov>, [">= 0"])
  s.add_dependency(%q<rails>, [">= 3.0.0"])
  s.add_dependency(%q<faker>, [">= 0"])
  s.add_dependency(%q<term-ansicolor>, [">= 0"])
end

