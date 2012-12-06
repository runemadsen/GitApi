require 'git-api'
require 'test/unit'
require 'rack/test'
require 'fileutils'
require 'grit'
require 'json'

ENV['RACK_ENV'] = 'test'
GIT_PATH = "/tmp/testrepos"
GIT_REPO = "mytestrepo"

class TestHelpers
	class << self

		def testfile(filename)
			File.open("#{File.dirname(__FILE__)}/testfiles/#{filename}")
		end

	end
end