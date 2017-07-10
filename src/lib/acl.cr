require "./acl/*"

module Wikicr
  Dir.mkdir_p "meta"

  File.touch "meta/users"
  DEFAULT_USER = Wikicr::User.new "guest", "guest", %w(guest)
  USERS        = Wikicr::Users.new "meta/users", DEFAULT_USER

  # File.touch "meta/acl"
  ACL = Acl::Groups.new("meta/acl")
end

pp Wikicr::ACL.read!.groups_having "/home"
