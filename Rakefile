require 'rake'
require 'jeweler'
require 'rspec'
require 'rspec/core/rake_task'

Jeweler::Tasks.new do |gem|
  
  gem.name        = "authorize_cim"
  gem.summary     = %Q{Ruby Gem for integrating Authorize.net Customer Information Manager (CIM)}
  gem.description = %Q{Ruby Gem for integrating Authorize.net Customer Information Manager (CIM)}
  # gem.email     = "josh@technicalpickles.com"
  gem.homepage    = "http://github.com/tylerflint/authorize_cim"
  gem.authors     = ["Tyler Flint", "Lyon Hill"]
  gem.files       = Dir["{lib}/**/*", "{spec}/**/*","[A-Z]*"]
  
  # gem.add_dependency "name"
  
end

desc "Run all specs"
RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = ['--colour --format progress']
end

task :default => :spec
