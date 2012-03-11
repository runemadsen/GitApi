module GitApi
  module Helpers
    
    def json_reponse(object)      
      if object.is_a?(Grit::Repo)
        repo_json(object)
      end
    end
    
    def repo_json(repo)
      { 
        :path => repo.path
      }.to_json
    end
    
  end
end