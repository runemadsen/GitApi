module GitApi
  module Helpers
    
    def make_file(repo, branch, name, contents, encoding, user, email, message)
      repo = Grit::Repo.new(File.join(settings.git_path, repo))
      index = Grit::Index.new(repo)
      index.read_tree(branch)
      index.add(name, contents)
      sha = index.commit(message, repo.commit_count > 0 ? [repo.commit(branch)] : nil, Grit::Actor.new(user, email), nil, branch)
    end
    
  end
end