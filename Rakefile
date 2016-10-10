require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |task|
  task.libs << "test"

  task.test_files = Dir['test/**/*_test.rb'].reject do |path|
    /(examples)/ =~ path
  end

  task.verbose = true
  task.warning = true
end

task :default => :test
