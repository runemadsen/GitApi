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
    
    # Get basic repo information.
    #
    # :repo      - The String name of the repo (including .git)
    #
    # Returns a JSON string of the created repo
    get '/gitapi/v1/repos/:repo' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      repo_to_hash(repo).to_json
    end
    
    # Create a new bare Git repository.
    #
    # name     - The String name of the repository. The ".git" extension will be added if not provided
    # hooks[]  - The String array of hooks to enable when creating the repo (e.g. ["post-update", "post-receive"])
    #
    # Returns a JSON string of the created repo 
    post '/gitapi/v1/repos' do
      repo_name = params[:name]
      repo_name += ".git" unless repo_name =~ /\.git/
      repo = Grit::Repo.init_bare(File.join(settings.git_path, repo_name))
      enable_hooks(File.join(settings.git_path, repo_name), params[:hooks]) if params[:hooks]
      repo_to_hash(repo).to_json
    end
    
    # Get a list of all branches in repo.
    #
    # :repo      - The String name of the repo (including .git)
    #
    # Returns a JSON string containing an array of all branches in repo
    get '/gitapi/v1/repos/:repo/branches' do
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
    get '/gitapi/v1/repos/:repo/branches/:branch/files' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      tree = repo.tree(params[:branch])
      tree_to_hash(tree).to_json
    end
    
    # Get file (if file is specified) or array of files (if folder is specified) in branch.
    #
    # :repo     - The String name of the repo (including .git)
    # :branch   - The String name of the branch (e.g. "master")
    # :*        - The String name of the file or folder. Can be path in a subfolder (e.g. "images/thumbs/myfile.jpg")
    # encoding  - If a single blob is returned, this encoding is used for the blob data (defaults to utf-8)
    #
    # Returns a JSON string containing file content or an array of file names
    get '/gitapi/v1/repos/:repo/branches/:branch/files/*' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      gitobject = get_object_from_tree(repo, params[:branch], params[:splat].first)
      if(gitobject.is_a?(Grit::Tree))  
        tree_to_hash(gitobject).to_json
      else
        encoding = params[:encoding] || "utf-8"
        blob_to_hash(gitobject, encoding).to_json
      end
    end
    
    # Commit a new file and its data to specified branch. This methods loads all current files in specified branch (or from_branch) into index
    # before committing the new file.
    #
    # :repo       - The String name of the repo (including .git)
    # :branch     - The String name of the branch (e.g. "master")
    # name        - The String name of the file (can be a path in folder)
    # data        - The String data of the file
    # encoding    - The String encoding of the data ("utf-8" or "base64")
    # user        - The String name of the commit user
    # email       - The String email of the commit user
    # message     - The String commit message
    # from_branch - (Optional) The String of a specific branch whose tree should be loaded into index before committing. Use if creating a new branch.
    #
    # Returns a JSON string containing sha of the commit
    post '/gitapi/v1/repos/:repo/branches/:branch/files' do
      sha = make_file(params[:repo], params[:branch], params[:name], params[:data], params[:encoding], params[:user], params[:email], params[:message], params[:from_branch])
      commit_to_hash(sha).to_json
    end
    
    # Delete a file from the specified branch and commit the deletion. This methods loads all current files in specified branch into index
    # before doing the deletion.
    #
    # :repo     - The String name of the repo (including .git)
    # :branch   - The String name of the branch (e.g. "master")
    # :*        - The String name of the file or folder. Can be path in a subfolder (e.g. "images/thumbs/myfile.jpg")
    # user      - The String name of the commit user
    # email     - The String email of the commit user
    # message   - The String commit message
    #
    # Returns a JSON string containing sha of the commit
    delete '/gitapi/v1/repos/:repo/branches/:branch/files/*' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      index = Grit::Index.new(repo)
      index.read_tree(params[:branch])
      index.delete(params[:splat].first)
      sha = index.commit(params[:message], [repo.commit(params[:branch])], Grit::Actor.new(params[:user], params[:email]), nil, params[:branch])
      commit_to_hash(sha).to_json
    end
    
    # Commit a new file and its data to specified branch. This methods loads all current files in specified branch (or from_branch) into index
    # before committing the new file.
    #
    # :repo       - The String name of the repo (including .git)
    # :branch     - The String name of the branch (e.g. "master")
    # name        - The String name of the file (can be a path in folder)
    # data        - The String data of the file
    # encoding    - The String encoding of the data ("utf-8" or "base64")
    # user        - The String name of the commit user
    # email       - The String email of the commit user
    # message     - The String commit message
    # from_branch - (Optional) The String of a specific branch whose tree should be loaded into index before committing. Use if creating a new branch.
    #
    # Returns a JSON string containing sha of the commit
    post '/gitapi/v1/repos/:repo/branches/:branch/files' do
      sha = make_file(params[:repo], params[:branch], params[:name], params[:data], params[:encoding], params[:user], params[:email], params[:message], params[:from_branch])
      commit_to_hash(sha).to_json
    end
    
    #  Blobs
    #--------------------------------------------------------
    
    # Get blob data from blob sha.
    #
    # repo      - The String name of the repo (including .git)
    # sha       - The String sha of the blob
    #
    # Returns a JSON string containing the data of blob
    get '/gitapi/v1/repos/:repo/blobs/:sha' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      blob = get_blob(repo, params[:sha])
      blob_to_hash(blob).to_json  
    end
    
    #  Refs
    #--------------------------------------------------------
    
    # Get all references in repo.
    #
    # repo      - The String name of the repo (including .git)
    #
    # Returns a JSON string containing an array of all references
    get '/gitapi/v1/repos/:repo/refs' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      repo.refs_list.map { |ref| ref_to_hash(ref) }.to_json
    end
    
    # Create a new reference.
    #
    # repo  - The String name of the repo (including .git)
    # ref   - The String name of the ref (can currently only create refs/heads, e.g. "master")
    # sha   - String of the SHA to set this reference to  
    #
    # Returns a JSON string containing an array of all references
    post '/gitapi/v1/repos/:repo/refs' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      sha = repo.update_ref(params[:ref], params[:sha])
      commit_to_hash(sha).to_json
    end
    
    #  Tags
    #--------------------------------------------------------
    
    # Get all tags in repo. This does not return lightweight tags (tags without a ref).
    #
    # repo      - The String name of the repo (including .git)
    #
    # Returns a JSON string containing an array of all references
    get '/gitapi/v1/repos/:repo/tags' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
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
    # Returns a JSON string containing the data of blob
    post '/gitapi/v1/repos/:repo/tags' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      actor = Grit::Actor.new(params[:user], params[:email])
      Grit::Tag.create_tag_object(repo, params, actor).to_json
    end
    
    #  Blame
    #--------------------------------------------------------
    
    # Get blame for a specific file in the repo
    #
    # repo      - The String name of the repo (including .git)
    # :branch   - The String name of the branch (e.g. "master")
    # :*        - The String name of the file. Can be path in a subfolder (e.g. "subfolder/myfile.txt")
    #
    # Returns a JSON string containing an array of all references
    get '/gitapi/v1/repos/:repo/blame/*' do
      repo = get_repo(File.join(settings.git_path, params[:repo]))
      #repo.blame
    end
    
  end
  
end