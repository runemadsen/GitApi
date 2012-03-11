require 'git-api'
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'
GIT_PATH = "/tmp/testrepos"

class GitApiTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    GitApi::App.set :git_path => GIT_PATH
    GitApi::App
  end

  def test_create_repo_without_extension
    post '/repos', {:name => "mytestrepo"}
    assert last_response.ok?
    assert_equal({ :path => File.join(GIT_PATH, "mytestrepo.git")}.to_json, last_response.body)
  end
  
end