# This file is only for testing on localhost!!

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
require 'git-api.rb'

# Setup git api
# --------------------------------------------------------

GitApi::App.set :git_path => "/usr/local/app/repos"
map '/gitapi' do
  run GitApi::App
end