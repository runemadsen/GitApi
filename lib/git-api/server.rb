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
    
    # Get a list of all branches in repo.
    #
    # :repo      - The String name of the repo (including .git)
    #
    # Returns a JSON string containing an array of all branches in repo
    get '/repos/:repo/branches' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      heads = repo.heads
      heads.map { |head| head_to_hash(head) }.to_json
    end

    # Get a list of all files in the branch root folder.
    #
    # :repo      - The String name of the repo (including .git)
    # :branch    - The String name of the branch (e.g. "master")
    #
    # Returns a JSON string containing an array of all files in branch, plus sha of the tree
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
    
    # Commit a new file and its contents to specified branch. This methods loads all current files in specified branch (or from_branch) into index
    # before committing the new file.
    #
    # :repo       - The String name of the repo (including .git)
    # :branch     - The String name of the branch (e.g. "master")
    # name        - The String name of the file.
    # contents    - The String contents of the file
    # encoding    - The String encoding of the contents ("utf-8" or "base64")
    # user        - The String name of the commit user
    # email       - The String email of the commit user
    # message     - The String commit message
    # from_branch - (Optional) The String of a specific branch whose tree should be loaded into index before committing. Use if creating a new branch.
    #
    # Returns a JSON string containing sha of the commit
    post '/repos/:repo/branches/:branch/files' do
      sha = make_file(params[:repo], params[:branch], params[:name], params[:contents], params[:encoding], params[:user], params[:email], params[:message], params[:from_branch])
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
    # POST  /repos/:repo/branches - create branch
    
    #  Blobs
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
    
    #  Refs
    #--------------------------------------------------------
    
    # Get all references in repo
    #
    # repo      - The String name of the repo (including .git)
    #
    # Returns a JSON string containing an array of all references
    get '/repos/:repo/refs' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      repo.refs_list.map { |ref| ref_to_hash(ref) }.to_json
    end
    
    # Create a new reference
    #
    # repo  - The String name of the repo (including .git)
    # ref   - The String name of the ref (can currently only create refs/heads, e.g. "master")
    # sha   - String of the SHA to set this reference to  
    #
    # Returns a JSON string containing an array of all references
    post '/repos/:repo/refs' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      sha = repo.update_ref(params[:ref], params[:sha])
      { :commit_sha => sha }.to_json
    end
    
    #  Tags
    #--------------------------------------------------------
    
    # Get all tags in repo
    #
    # repo      - The String name of the repo (including .git)
    #
    # Returns a JSON string containing an array of all references
    get '/repos/:repo/tags' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      puts repo.tags.inspect
      repo.tags.map { |tag| tag_to_hash(head) }.to_json
    end
    
    # Create new tag in repo. Note that creating a tag object does not create the reference that makes a tag in Git. 
    # If you want to create an annotated tag in Git, you have to do this call to create the tag object, and then 
    # create the refs/tags/[tag] reference. If you want to create a lightweight tag, you simply have to create 
    # the reference - this call would be unnecessary.
    #
    # repo      - The String name of the repo (including .git)
    # tag       - The String name of the tag
    # message   - The String tag message
    # sha       - The String sha of the object being tagged (usually a commit sha, but could be a tree or a blob sha)
    # type      - The String type of the object being tagged (usually "commit", but could be "tree" or "blob")
    # user      - The String name of the commit user
    # email     - The String email of the commit user
    # 
    #
    # Returns a JSON string containing the contents of blob
    post '/repos/:repo/tags' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      actor = Grit::Actor.new(params[:user], params[:email])
      Grit::Tag.create_tag_object(repo, params, actor).to_json
    end
    
    # TODO
    # make tests that give wrong params to all the functions
    # POST  /repos/:repo/blobs
    # GET   /repos/:repo/commits/:sha
    # POST  /repos/:repo/commits
    # POST  /repos/:repo/refs
    # GET   /repos/:repo/refs/:ref
    # PATCH /repos/:repo/refs/:ref
    # GET   /repos/:repo/tags/:sha
    # GET   /repos/:repo/tags
    # GET   /repos/:repo/trees/:sha
    # POST  /repos/:repo/trees
    
  end
  
end