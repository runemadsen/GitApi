require 'git-api'
require 'test/unit'
require 'rack/test'
require 'fileutils'
require 'grit'

ENV['RACK_ENV'] = 'test'
GIT_PATH = "/tmp/testrepos"

class GitApiTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    GitApi::App.set :git_path => GIT_PATH
    GitApi::App
  end
  
  # Repo creation
  # ------------------------------------------------------------------

  def test_create_repo_without_extension
    post '/repos', {:name => "mytestrepo"}
    path = File.join(GIT_PATH, "mytestrepo.git")
    assert last_response.ok?
    assert_equal({ :path => path}.to_json, last_response.body)
    FileUtils.rm_rf path
  end
  
  def test_create_repo_with_extension
    post '/repos', {:name => "mytestrepo.git"}
    path = File.join(GIT_PATH, "mytestrepo.git")
    assert last_response.ok?
    assert_equal({ :path => path}.to_json, last_response.body)
    FileUtils.rm_rf path
  end
  
  # File Creation
  # ------------------------------------------------------------------
  
  def test_create_file
    post '/repos', {:name => "mytestrepo"}
    post '/repos/mytestrepo.git/branches/master/files', {:name => "myfile.txt", :contents => "Hello There", :encoding => "utf-8", :user => "Rune Madsen", :email => "rune@runemadsen.com", :message => "My First Commit"}
    path = File.join(GIT_PATH, "mytestrepo.git")
    blob = Grit::Repo.new(path).tree("master")/"myfile.txt"
    assert last_response.ok?
    assert_equal(blob.data, "Hello There")
    assert last_response.body.include?("commit_sha")
  end
  
  
  
end