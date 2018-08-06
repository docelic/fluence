require "markdown"
require "yaml"
require "json"
require "kemal"
require "kemal-session"
require "kemal-flash"
require "kilt/slang"

require "../fluence/version"
require "../fluence/lib/_init"

require "../fluence/controllers/application_controller"

require "./routes"

Kemal::Session.config do |config|
  config.cookie_name = "session_id"
  config.secret = ENV["WIKI_SECRET"]? || Random::Secure.base64(64)
  config.gc_interval = 2.minutes # 2 minutes
end
