require "rake"
require "rake/testtask"

task :default => [:test]

desc "Run all tests"
task :test => ["test:unit", "test:integration", "test:end_to_end"]

namespace :test do
  Rake::TestTask.new(:unit) do |t|
    t.libs << "test"
    t.test_files = FileList['test/unit/**/*_test.rb']
    t.verbose = true
  end

  Rake::TestTask.new(:integration) do |t|
    t.libs << "test"
    t.test_files = FileList['test/integration/**/*_test.rb']
    t.verbose = true
  end

  Rake::TestTask.new(:end_to_end) do |t|
    t.libs << "test"
    t.test_files = FileList['test/end-to-end/**/*_test.rb']
    t.verbose = true
  end
end
