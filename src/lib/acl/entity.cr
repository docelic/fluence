require "./acl"
require "./group"

module Wikicr::ACL::Entity
  abstract def has_group?(group : String) : Bool
  abstract def groups : Array(String)
end
