require "./options"

require "./lockable"
require "./errors"
require "./git"

require "./**"

module Fluence
  # The dir *meta* contains users account (with encrypted password),
  # the index of the pages (with table of content, links, titles, ...)
  # and user permissions
  Dir.mkdir_p "meta"

	Dir.mkdir_p Fluence::Page.subdirectory
	Dir.mkdir_p Fluence::Media.subdirectory

  # Define a default user that should be used for anonymous clients
  DEFAULT_USER = Fluence::User.new "guest", "guest", %w(guest)

  # The list of users is stored in *meta/users*. This file is updated when
  # a user is created/modified/deleted, but data is stored in RAM for
  # efficiency.
  USERS = Fluence::Users.new("meta/users", DEFAULT_USER).load!

  # The list of permissions (group => path+permission) is stored in
  # file *meta/acl*. Similar behavior like `USERS`.
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
    ACL["user"]["/media*"] = Acl::Perm::Write
    ACL["user"]["/admin*"] = Acl::Perm::Write
    ACL.save!
  end

  # The list of pages (index) with a lot of meta-data. Same behavior like
  # `USERS` and `ACL`.
	INDEX = if File.exists? "meta/index"
		Fluence::Page::Index.new("meta/index").load!
	else
		Fluence::Page::Index.build("data/pages")
	end
end
