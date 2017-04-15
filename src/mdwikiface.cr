require "markdown"

require "kemal"
require "crystal-libgit2"

require "./mdwikiface/*"

module Mdwikiface
  REPO = Libgitit2.open_repository(".")
end

Kemal.run
