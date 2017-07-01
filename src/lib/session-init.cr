Session.config do |config|
  config.cookie_name = "session_id"
  config.secret = ENV["WIKI_SECRET"]
  config.gc_interval = 2.minutes # 2 minutes
end

macro user_must_be_logged!(env)
  if env.session.string?("username")
    puts "You are authenticated"
    # continue
  else
    puts "You are not authenticated"
    env.redirect "/users/login"
    next
  end
end
