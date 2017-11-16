# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "migrant"
  spec.version       = File.read('VERSION')
  spec.authors       = ["Pascal Houliston"]
  spec.email         = ["101pascal@gmail.com"]

  spec.summary       = %q{All the fun of ActiveRecord without writing your migrations, and with a dash of mocking.}
  spec.description   = %q{Easier schema management for Rails that complements your domain model.}
  spec.homepage      = %q{http://github.com/pascalh1011/migrant}
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  rails_version = ENV['RAILS_VERSION'] || '5.1'
 
  spec.add_development_dependency "rails", "~> #{rails_version}"
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sqlite3", ">= 1.3.13"
  spec.add_development_dependency "simplecov", ">= 0.15.1"
  
  spec.add_runtime_dependency "erubi", ">= 1.7.0"
  spec.add_runtime_dependency "term-ansicolor", ">= 1.6.0"
  spec.add_runtime_dependency "faker", ">= 1.8.4"
end
