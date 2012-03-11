require 'sinatra'
require 'grit'
require 'json'

module GitApi
  
  class App < Sinatra::Base
    
    helpers Helpers
    
    before do
      content_type 'application/json'
    end
    
    #  Higher Level Git
    #--------------------------------------------------------
    
    # Create a new bare Git repository.
    #
    # name  - The String name of the repository. The ".git" extension will be added if not provided
    #
    # Examples
    #
    #   curl -d "name=myrepo" http://myserver.com/repos
    #
    # Returns a JSON string of the created repo 
    post '/repos' do
      repo_name = params[:name]
      repo_name += ".git" unless repo_name =~ /\.git/
      repo = Grit::Repo.init_bare(File.join(settings.git_path, repo_name))
      #`mv #{git_repo}/hooks/post-update.sample #{git_repo}/hooks/post-update`
      json_reponse(repo)
    end
    
    # GET   /repos/:repo - get repo information (with clone url if set in Sinatra)
    # PATCH /repos/:repo - edit repo (only name now)
    # GET   /repos/:repo/branches - list all branches
    # POST  /repos/:repo/branches - create branch
    # GET   /repos/:repo/branches/:branch - list all files in branch
    # POST  /repos/:repo/branches/:branch/files - commit new file in branch
    # PUT   /repos/:repo/branches/:branch/files - commit array of files in branch (overrides all files and deletes the one not in array)
    # GET   /repos/:repo/branches/:branch/files/:filename - get file data in branch
    # PUT   /repos/:repo/branches/:branch/files/:filename - commit update on file in branch
    
    #  Lower Level Git
    #--------------------------------------------------------
    
    # GET   /repos/:repo/blobs/:sha
    # POST  /repos/:repo/blobs
    # GET   /repos/:repo/commits/:sha
    # POST  /repos/:repo/commits
    # GET   /repos/:repo/refs
    # POST  /repos/:repo/refs
    # GET   /repos/:repo/refs/:ref
    # PATCH /repos/:repo/refs/:ref
    # GET   /repos/:repo/tags/:sha
    # POST  /repos/:repo/tags
    # GET   /repos/:repo/tags
    # GET   /repos/:repo/trees/:sha
    # POST  /repos/:repo/trees
    
  end
  
end