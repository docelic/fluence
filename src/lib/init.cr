require "./options"

require "./lockable"
require "./errors"
require "./acl/**"
require "./users/**"
require "./files/**"

module Wikicr
  Dir.mkdir_p "meta"

  DEFAULT_USER = Wikicr::User.new "guest", "guest", %w(guest)
  USERS        = Wikicr::Users.new "meta/users", DEFAULT_USER

  # File.touch "meta/acl"
  ACL = Acl::Groups.new("meta/acl").load!

  # Initialize the ACLs
  if ACL["guest"]?.nil?
    ACL.add("guest")
    ACL["guest"]["/users/*"] = Acl::Perm::Write
    ACL["guest"]["/sitemap"] = Acl::Perm::Read
    ACL["guest"]["/pages*"] = Acl::Perm::Read
    ACL.add("user")
    ACL["user"]["/*"] = Acl::Perm::Read
    ACL["user"]["/users/login"] = Acl::Perm::None
    ACL["user"]["/users/register"] = Acl::Perm::None
    ACL["user"]["/pages*"] = Acl::Perm::Write
    ACL.save!
  end

  PAGES = Wikicr::Page::Index.new("meta/index").load!
end
