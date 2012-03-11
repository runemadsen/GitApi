task :test do
  $LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
  require 'git-api.rb'
  Dir.glob("./test/*_test.rb").each do |file|
   require file
  end
end
