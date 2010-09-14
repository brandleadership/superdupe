require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'

desc 'Default: run specs.'
task :default => :spec

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  desc "Run all specs with RCov"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec,/Library']
  end
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = "superdupe"
    gemspec.summary     = "A tool that helps you mock services while cuking."
    gemspec.description = "SuperDupe is a fork of the originally Dupe and rides on top of ActiveResource to allow you to cuke the client side of 
                           a service-oriented app without having to worry about whether or not the service is live or available while cuking."
    gemspec.email       = "marco.ribi@screenconcept.ch"
    gemspec.files       = FileList['lib/**/*.rb', 'rails_generators/**/*', 'README.markdown']
    gemspec.homepage    = "http://github.com/screenconcept/dupe"
    gemspec.authors     = ["Marco Ribi"]
    gemspec.add_dependency('activeresource', '>= 2.3.3')
  end
  
  Jeweler::GemcutterTasks.new
  
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end


require 'rake'
require 'spec/rake/spectask'

desc "Code Coverage"
Spec::Rake::SpecTask.new('rcov') do |t|
  t.spec_files = FileList['spec/lib_specs/*.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,rails_generators,pkg,rubygems/*,/Library/Ruby/Site/*,gems/*']
end
