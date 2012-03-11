GitApi Gem
----------

The GitApi is a gem that makes it easy to provide RESTful API access to Git repositories on a Git server. Modern scalable web architectures (like Heroku) does not have local storage, which means that application code and git server often live on separate networks. This gem includes a Sinatra application that exposes most Git functionality via HTTP routes, inspired by the Github API V3.

The gem is meant to live alongside the Grack gem created by @schacon. Grack can expose your git repositories via the git-protocol in a pure Ruby implementation, and GitApi can make it possible to interact with these repositories over HTTP (no need for cloning and pushing repos from your app code).