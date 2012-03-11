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
    
    def get_file_from_tree(repo, tree, name)
      blob = repo.tree(tree)/name
      throw(:halt, [404, "Blob Not Found"]) if blob.nil?
      blob
    end
    
    def make_file(repo, branch, name, contents, encoding, user, email, message)
      repo = get_repo(File.join(settings.git_path, repo))
      index = Grit::Index.new(repo)
      index.read_tree(branch)
      index.add(name, contents)
      sha = index.commit(message, repo.commit_count > 0 ? [repo.commit(branch)] : nil, Grit::Actor.new(user, email), nil, branch)
    end
    
  end
end