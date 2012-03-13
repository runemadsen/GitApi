$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
require 'git-api.rb'

GitApi::App.set :git_path => "/tmp/testrepos"

run GitApi::App