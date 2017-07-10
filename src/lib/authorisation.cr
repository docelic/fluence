module Wikicr
  Dir.mkdir_p "meta"

  DEFAULT_USER = Wikicr::User.new "guest", "guest", %w(guest)
  USERS        = Wikicr::Users.new "meta/users", DEFAULT_USER

  # File.touch "meta/acl"
  ACL   = Acl::Groups.new("meta/acl").read!
  ACL.add("guest") if ACL["guest"]?.nil?
  GUEST = ACL["guest"]
end

macro user_must_be_logged!(env)
  if user_signed_in?(env)
    puts "You are authenticated"
    # continue
  else
    puts "You are not authenticated"
    env.redirect "/users/login"
    next
  end
end

macro user_must_be_logged!
  user_must_be_logged!(env)
end

macro user_must_be_admin!(env)
  if current_user.has_group?("admin")
    puts "You are admin"
  else
    puts "You are not admin"
    env.redirect "/"
    next
  end
end

macro user_must_be_admin!
  user_must_be_admin!(env)
end

macro user_signed_in?(env)
  env.session.string?("username")
end

macro user_signed_in?
  user_signed_in?(env)
end

macro current_user(env)
  %name = user_signed_in?(env)
  if (%name.nil?)
    Wikicr::USERS.default || raise "User not signed in"
  else
    Wikicr::USERS.find(%name)
  end
end

macro current_user
  current_user(env)
end

macro acl_permit!(perm, env)
  # read env.query.path ...
  # Wikicr::ACL.permitted?(current_user, path, env)
end

macro acl_permit!(perm)
  acl_permit!(perm, env)
end
