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
    
    def make_file(repo, branch, name, contents, encoding, user, email, message)
      repo = get_repo(File.join(settings.git_path, repo))
      index = Grit::Index.new(repo)
      index.read_tree(branch)
      index.add(name, contents)
      sha = index.commit(message, repo.commit_count > 0 ? [repo.commit(branch)] : nil, Grit::Actor.new(user, email), nil, branch)
    end
    
  end
end