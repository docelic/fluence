Kemal::Session.config do |config|
  config.cookie_name = "session_id"
  config.secret = ENV["WIKI_SECRET"]
  config.gc_interval = 2.minutes # 2 minutes
end
