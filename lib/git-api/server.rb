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
    # Returns a JSON string of the created repo 
    post '/repos' do
      repo_name = params[:name]
      repo_name += ".git" unless repo_name =~ /\.git/
      repo = Grit::Repo.init_bare(File.join(settings.git_path, repo_name))
      #`mv #{git_repo}/hooks/post-update.sample #{git_repo}/hooks/post-update`
      
      { :path => repo.path }.to_json
    end
    
    # GET   /repos/:repo - get repo information (with clone url if set in Sinatra)
    # PATCH /repos/:repo - edit repo (only name now)
    # GET   /repos/:repo/branches - list all branches
    # POST  /repos/:repo/branches - create branch

    # Get a list of all files in master.
    #
    # repo      - The String name of the repo (including .git)
    # branch    - The String name of the branch (e.g. "master")
    #
    # Returns a JSON string containing and array of all files in master, plus sha of tree
    get '/repos/:repo/branches/:branch/files' do
      repo = Grit::Repo.new(File.join(settings.git_path, params[:repo]))
      tree = repo.tree(params[:branch])
      files = tree.contents.map do |blob|
        { :name => blob.name }
      end
      { :files => files, :tree_sha => tree.id }.to_json
    end
    
    # Commit a new file and its contents to specified branch. This methods loads all current files in specified branch into index
    # before committing the new file.
    #
    # repo      - The String name of the repo (including .git)
    # branch    - The String name of the branch (e.g. "master")
    # name      - The String name of the file.
    # contents  - The String contents of the file
    # encoding  - The String encoding of the contents ("utf-8" or "base64")
    # user      - The String name of the commit user
    # email     - The String email of the commit user
    # message   - The String commit message
    #
    # Returns a JSON string containing sha of the commit
    post '/repos/:repo/branches/:branch/files' do
      repo = Grit::Repo.new(File.join(settings.git_path, params[:repo]))
      index = Grit::Index.new(repo)
      index.read_tree(params[:branch])
      index.add(params[:name], params[:contents])
      sha = index.commit(params[:message], repo.commit_count > 0 ? [repo.commit(params[:branch])] : nil, Grit::Actor.new(params[:user], params[:email]), nil, params[:branch])
      { :commit_sha => sha }.to_json
    end
    
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