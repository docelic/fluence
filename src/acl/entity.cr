require "./perm"
require "./group"

# Entity that have access to the Acl system.
module Acl::Entity
  # Returns `true` if the *group* is owned by `Entity`, else `false`
  abstract def group?(group : String) : Bool

  # Returns the list of group names of `Entity`
  abstract def groups : Array(String)
end
