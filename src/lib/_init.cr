require "./options"
require "./git"

require "./lockable"
require "./errors"

require "./**"

module Fluence
  # The dir *meta* contains users account (with encrypted password),
  # the index of the pages (with table of content, links, titles, ...)
  # and user permissions
  Dir.mkdir_p "meta"

  # Define a default user that should be used for anonymous clients
  DEFAULT_USER = Fluence::User.new "guest", "guest", %w(guest)

  # The list of the users is stored into *meta/users*. This file is updated when
  # an user is created/modified/deleted, but the data are stored into RAM for
  # reading.
  USERS = Fluence::Users.new("meta/users", DEFAULT_USER).load!

  # The list of the permissions (group => path+permission) is stored into the
  # file *meta/acl. Similar behaviour than `USERS`.
  ACL = Acl::Groups.new("meta/acl").load!

  # If there is no "guest", we assume that the ACL have not been initialized yet
  # and we create a group "guest" and "user".
  # TODO: a proper "installation" procedure should be made to avoid these kind
  # of operation in a scope
  if ACL["guest"]?.nil?
    ACL.add("guest")
    ACL["guest"]["/users/*"] = Acl::Perm::Write
    ACL["guest"]["/sitemap"] = Acl::Perm::Read
    ACL["guest"]["/pages*"] = Acl::Perm::Read
    ACL["guest"]["/"] = Acl::Perm::Read
    ACL.add("user")
    ACL["user"]["/*"] = Acl::Perm::Read
    ACL["user"]["/users/login"] = Acl::Perm::None
    ACL["user"]["/users/register"] = Acl::Perm::None
    ACL["user"]["/pages*"] = Acl::Perm::Write
    ACL.save!
  end

  # The list of the pages (index) with a lot of meta-data. Same behaviour than
  # `USERS` and `ACL`.
  PAGES = Fluence::Page::Index.new("meta/index").load!
end
