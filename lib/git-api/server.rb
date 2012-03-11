module GitApi
  
  class App < Sinatra::Base
    
    before do
      content_type 'application/json'
    end
    
    #  Higher Level Git
    #--------------------------------------------------------
    
    # POST  /repos - create repo
    # GET   /repos/:repo - get repo information (with clone url if set in Sinatra)
    # PATCH /repos/:repo - edit repo (only name now)
    # GET   /repos/:repo/branches - list all branches
    # POST  /repos/:repo/branches - create branch
    # GET   /repos/:repo/branches/:branch - list all files in branch
    
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