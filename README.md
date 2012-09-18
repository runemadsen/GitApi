GitApi Gem
----------

The GitApi is a gem that makes it easy to provide RESTful API access to Git repositories on a server. Modern scalable web architectures (like Heroku) do not have local storage, which means that application code and the git server often live on separate networks. This gem includes a Sinatra application that exposes most Git functionality via HTTP routes, inspired by the Github API V3.

The API provides both lower-level read/write access to the Git objects (Blobs, Trees, Commits, Refs, Tags, etc) and a series of higher-level routes that combines actions that otherwise would take too many API calls to do (update file in specific branch, etc).

The gem is meant to live alongside the Grack gem created by @schacon. Grack can expose your git repositories via the git-protocol in a pure Ruby implementation, and GitApi makes it possible to interact with these repositories over HTTP (no need for cloning and pushing repos from your app code).