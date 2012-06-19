require 'iconv'
require 'linguist'

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
    
    def make_file(repo, branch, name, data, encoding, user, email, message, from_branch = nil)
      repo = get_repo(File.join(settings.git_path, repo))
      index = Grit::Index.new(repo)
      index.read_tree(from_branch || branch)
      index.add(name, data)
      sha = index.commit(message, repo.commit_count > 0 ? [repo.commit(from_branch || branch)] : nil, Grit::Actor.new(user, email), nil, branch)
    end
    
    def enable_hooks(repo, hooks)
      hooks.each do |hook|
        `mv #{repo}/hooks/#{hook}.sample #{repo}/hooks/#{hook}`
      end
    end
    
    # Object to Hash conversion
    # ---------------------------------------------------
    
    def repo_to_hash(repo)
      { :path => repo.path }
    end
    
    def tree_to_hash(tree)
      files = tree.contents.map do |object|
        { :name => object.name, :type => object.class.name.downcase.split('::').last }
      end
      { :files => files, :sha => tree.id, :type => :tree }
    end

    def blob_to_hash(blob, encoding = "utf-8")
      { 
        :name => blob.name,
        :data => blob.data.force_encoding(encoding),
        :type => :blob
      }
    end
    
    def head_to_hash(head)
      {
        :name => head.name,
        :commit_sha => head.commit.id,
        :type => :head
      }
    end
    
    def ref_to_hash(ref)
      {
        :ref => ref[0],
        :sha => ref[1],
        :type => ref[2]
      }
    end
    
    def commit_to_hash(sha)
      {
        :sha => sha,
        :type => :commit
      }
    end
    
    def commit_baked_to_hash(commit)
      {
        :id => commit.id,
        :parents => commit.parents.map { |p| { 'id' => p.id } },
        :tree => commit.tree.id,
        :message => iconv_utf8(commit.message),
        :author => {
          :name => commit.author.name,
          :email => commit.author.email
        },
        :committer => {
          :name => commit.committer.name,
          :email => commit.committer.email
        },
        :authored_date => commit.authored_date.xmlschema,
        :committed_date => commit.committed_date.xmlschema,
      }
    end
    
    def tag_to_hash(tag)
      
    end
    
    def diff_to_hash(diff)
      has_image = is_image?(diff.a_path) || is_image?(diff.b_path)
      {
        :a_path => diff.a_path,
        :b_path => diff.b_path,
        :a_mode => diff.a_mode,
        :b_mode => diff.b_mode,
        :new_file => diff.new_file,
        :deleted_file => diff.deleted_file,
        :renamed_file => diff.renamed_file,
        :similarity_index => diff.similarity_index,
        :diff => has_image ? "" : iconv_utf8(diff.diff)
      }
    end
    
    # Because grit has not encoded its strings, all strings come out as binary. This function converts
    # the binary string to utf-8.
    
    def iconv_utf8(s)
      Iconv.new('UTF-8//IGNORE', 'US-ASCII').iconv(s + ' ')[0..-2]
    end
    
    def is_image?(filename)
      Linguist::FileBlob.new(filename).image?
    end
    
  end
end