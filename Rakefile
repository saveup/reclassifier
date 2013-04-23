require 'bundler/gem_tasks'
require 'rdoc/task'
require 'rspec/core/rake_task'

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include('lib/**/*.rb')
end

RSpec::Core::RakeTask.new(:spec)
