$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
require 'git-api.rb'

# Setup git api
# --------------------------------------------------------

GitApi::App.set :git_path => "/tmp/testrepos"
map '/gitapi' do
  run GitApi::App
end