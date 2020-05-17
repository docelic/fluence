# No need to change defaults.

Kemal::Session.config do |config|
  config.cookie_name = "session_id"
  config.secret = ENV["WIKI_SECRET"]? || Random::Secure.base64(64)

  # Used by kemal-session
  config.gc_interval = 2.minutes # 2 minutes
end
