require 'rake'
require 'rake/testtask'
require 'bundler/setup'

Rake::TestTask.new do |t|
  t.libs << Dir.pwd
  t.test_files = FileList['test/test*.rb']
end

task :default => :test
