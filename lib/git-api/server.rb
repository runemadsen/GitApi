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
    
    # Get basic repo information
    #
    # :repo      - The String name of the repo (including .git)
    #
    # Returns a JSON string of the created repo
    get '/repos/:repo' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      repo_to_hash(repo).to_json
    end
    
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
      repo_to_hash(repo).to_json
    end

    # Get a list of all files in the branch root folder.
    #
    # :repo      - The String name of the repo (including .git)
    # :branch    - The String name of the branch (e.g. "master")
    #
    # Returns a JSON string containing and array of all files in branch, plus sha of the tree
    get '/repos/:repo/branches/:branch/files' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      tree = repo.tree(params[:branch])
      tree_to_hash(tree).to_json
    end
    
    # Get file (if file is specified) or array of files (if folder is specified) in branch
    #
    # :repo     - The String name of the repo (including .git)
    # :branch   - The String name of the branch (e.g. "master")
    # :*        - The String name of the file or folder. Can be path in a subfolder (e.g. "images/thumbs/myfile.jpg")
    #
    # Returns a JSON string containing file content or an array of file names
    get '/repos/:repo/branches/:branch/files/*' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      gitobject = get_object_from_tree(repo, params[:branch], params[:splat].first)
      if(gitobject.is_a?(Grit::Tree))  
        tree_to_hash(gitobject).to_json
      else
        blob_to_hash(gitobject).to_json
      end
    end
    
    # Commit a new file and its contents to specified branch. This methods loads all current files in specified branch into index
    # before committing the new file.
    #
    # :repo     - The String name of the repo (including .git)
    # :branch   - The String name of the branch (e.g. "master")
    # name      - The String name of the file.
    # contents  - The String contents of the file
    # encoding  - The String encoding of the contents ("utf-8" or "base64")
    # user      - The String name of the commit user
    # email     - The String email of the commit user
    # message   - The String commit message
    #
    # Returns a JSON string containing sha of the commit
    post '/repos/:repo/branches/:branch/files' do
      sha = make_file(params[:repo], params[:branch], params[:name], params[:contents], params[:encoding], params[:user], params[:email], params[:message])
      { :commit_sha => sha }.to_json
    end
    
    # Commit an update to a file and its contents to specified branch. This methods loads all current files in specified branch into index
    # before committing the new file. This is exactly the same as the equal POST route
    #
    # :repo     - The String name of the repo (including .git)
    # :branch   - The String name of the branch (e.g. "master")
    # name      - The String name of the file.
    # contents  - The String contents of the file
    # encoding  - The String encoding of the contents ("utf-8" or "base64")
    # user      - The String name of the commit user
    # email     - The String email of the commit user
    # message   - The String commit message
    #
    # Returns a JSON string containing sha of the commit
    put '/repos/:repo/branches/:branch/files' do
      sha = make_file(params[:repo], params[:branch], params[:name], params[:contents], params[:encoding], params[:user], params[:email], params[:message])
      { :commit_sha => sha }.to_json
    end
    
    # TODO
    # make the create/update/delete file functions accept array of files
    # PATCH /repos/:repo - edit repo (only name now)
    # GET   /repos/:repo/branches - list all branches
    # POST  /repos/:repo/branches - create branch
    
    #  Lower Level Git
    #--------------------------------------------------------
    
    # Get blob data from blob sha
    #
    # repo      - The String name of the repo (including .git)
    # sha       - The String sha of the blob
    #
    # Returns a JSON string containing the contents of blob
    get '/repos/:repo/blobs/:sha' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      blob = get_blob(repo, params[:sha])
      blob_to_hash(blob).to_json  
    end
    
    # TODO
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