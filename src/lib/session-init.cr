Session.config do |config|
  config.cookie_name = "session_id"
  config.secret = ENV["WIKI_SECRET"]
  config.gc_interval = 2.minutes # 2 minutes
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

macro user_signed_in?(env)
  env.session.string?("username")
end

macro current_user(env)
  %name = user_signed_in?(env)
  raise "User not signed in" if %name.nil?
  Wikicr::USERS.find(%name)
end
