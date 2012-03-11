require 'git-api'
require 'test/unit'
require 'rack/test'
require 'fileutils'
require 'grit'
require 'json'

ENV['RACK_ENV'] = 'test'
GIT_PATH = "/tmp/testrepos"
GIT_REPO = "mytestrepo"

class GitApiTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    GitApi::App.set :git_path => GIT_PATH
    GitApi::App
  end
  
  def path 
    File.join(GIT_PATH, GIT_REPO+".git")
  end
  
  # Repo creation
  # ------------------------------------------------------------------

  def test_create_repo_without_extension
    post '/repos', {:name => GIT_REPO}
    assert last_response.ok?
    assert_equal({ :path => path}.to_json, last_response.body)
    FileUtils.rm_rf path
  end
  
  def test_create_repo_with_extension
    post '/repos', {:name => GIT_REPO+".git"}
    assert last_response.ok?
    assert_equal({ :path => path}.to_json, last_response.body)
    FileUtils.rm_rf path
  end
  
  # Files
  # ------------------------------------------------------------------
  
  def test_create_file
    post '/repos', {:name => GIT_REPO}
    post "/repos/#{GIT_REPO}.git/branches/master/files", {:name => "myfile.txt", :contents => "Hello There", :encoding => "utf-8", :user => "Rune Madsen", :email => "rune@runemadsen.com", :message => "My First Commit"}
    blob = Grit::Repo.new(path).tree("master")/"myfile.txt"
    assert last_response.ok?
    assert_equal(blob.data, "Hello There")
    assert last_response.body.include?("commit_sha")
    FileUtils.rm_rf path
  end
  
  def test_update_file
    post '/repos', {:name => GIT_REPO}
    post "/repos/#{GIT_REPO}.git/branches/master/files", {:name => "myfile.txt", :contents => "Hello There", :encoding => "utf-8", :user => "Rune Madsen", :email => "rune@runemadsen.com", :message => "My First Commit"}
    blob = Grit::Repo.new(path).tree("master")/"myfile.txt"
    assert last_response.ok?
    assert_equal(blob.data, "Hello There")
    assert last_response.body.include?("commit_sha")
    FileUtils.rm_rf path
  end
  
  def test_read_files
    post '/repos', {:name => GIT_REPO}
    post "/repos/#{GIT_REPO}.git/branches/master/files", {:name => "myfile.txt", :contents => "Hello There", :encoding => "utf-8", :user => "Rune Madsen", :email => "rune@runemadsen.com", :message => "My First Commit"}
    post "/repos/#{GIT_REPO}.git/branches/master/files", {:name => "myfile2.txt", :contents => "Hello There Again", :encoding => "utf-8", :user => "Rune Madsen", :email => "rune@runemadsen.com", :message => "My First Commit"}
    get "/repos/#{GIT_REPO}.git/branches/master/files"
    json = JSON.parse(last_response.body)
    assert last_response.ok?
    assert_equal(json["files"].size, 2)
    assert_equal(json["files"][0]["name"], "myfile.txt")
    FileUtils.rm_rf path
  end
  
  def test_read_file
    post '/repos', {:name => GIT_REPO}
    post "/repos/#{GIT_REPO}.git/branches/master/files", {:name => "myfile.txt", :contents => "Hello There", :encoding => "utf-8", :user => "Rune Madsen", :email => "rune@runemadsen.com", :message => "My First Commit"}
    get "/repos/#{GIT_REPO}.git/branches/master/files/myfile.txt"
    json = JSON.parse(last_response.body)
    assert last_response.ok?
    assert_equal(json["name"], "myfile.txt")
    assert_equal(json["contents"], "Hello There")
    FileUtils.rm_rf path
  end
  
  
  
end