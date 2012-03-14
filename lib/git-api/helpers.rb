module GitApi
  module Helpers
    
    def get_repo(path)
      begin
        repo = Grit::Repo.new(path)
      rescue
        throw(:halt, [404, "Repository Not Found"])
      end
      repo
    end
    
    def get_blob(repo, sha)
      blob = repo.blob(sha)
      throw(:halt, [404, "Blob Not Found"]) if blob.nil?
      blob
    end
    
    def get_object_from_tree(repo, tree, name)
      gitobject = repo.tree(tree)/name
      throw(:halt, [404, "Blob Not Found"]) if gitobject.nil?
      gitobject
    end
    
    def make_file(repo, branch, name, contents, encoding, user, email, message, from_branch = nil)
      repo = get_repo(File.join(settings.git_path, repo))
      index = Grit::Index.new(repo)
      index.read_tree(from_branch || branch)
      index.add(name, contents)
      sha = index.commit(message, repo.commit_count > 0 ? [repo.commit(branch)] : nil, Grit::Actor.new(user, email), nil, branch)
    end
    
    # Object to Hash conversion
    # ---------------------------------------------------
    
    def repo_to_hash(repo)
      { :path => repo.path }
    end
    
    def tree_to_hash(tree)
      files = tree.contents.map do |blob|
        { :name => blob.name }
      end
      { :files => files, :tree_sha => tree.id }
    end
    
    def blob_to_hash(blob)
      { 
        :name => blob.name,
        :contents => blob.data
      }
    end
    
    def head_to_hash(head)
      {
        :name => head.name,
        :commit_sha => head.commit.id
      }
    end
    
    def ref_to_hash(ref)
      {
        :ref => ref[0],
        :sha => ref[1],
        :type => ref[2]
      }
    end
    
    def tag_to_hash(tag)
      
    end
    
  end
end