module Wikicr
  Dir.mkdir_p "meta"

  DEFAULT_USER = Wikicr::User.new "guest", "guest", %w(guest)
  USERS        = Wikicr::Users.new "meta/users", DEFAULT_USER

  # File.touch "meta/acl"
  ACL = Acl::Groups.new("meta/acl").read!

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

  GUEST = ACL["guest"]
end

macro user_must_be_logged!
  if user_signed_in?
    puts "You are authenticated"
    # continue
  else
    puts "You are not authenticated"
    redirect_to "/users/login"
    next
  end
end

macro user_must_be_admin!
  if current_user.has_group?("admin")
    puts "You are admin"
  else
    puts "You are not admin"
    redirect_to "/"
    next
  end
end

macro user_signed_in?
  session["username"]
end

macro current_user
  %name = user_signed_in?
  if (%name.nil?)
    Wikicr::USERS.default || raise "User not signed in"
  else
    Wikicr::USERS.find(%name)
  end
end

macro acl_permit!(perm)
  if Wikicr::ACL.permitted?(current_user, request.path, Acl::PERM[{{perm}}])
    puts "PERMITTED #{current_user} #{request.path} #{Acl::PERM[{{perm}}]}"
  else
    puts "NOT PERMITTED #{current_user} #{request.path} #{Acl::PERM[{{perm}}]}"
  end
end
