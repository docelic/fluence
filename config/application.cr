require "markd"
require "yaml"
require "json"
require "kemal"
require "kemal-session"
require "kemal-flash"
require "kilt/slang"

require "../src/fluence/version"
require "../src/fluence/lib/_init"
require "../src/fluence/controllers/application_controller"
require "./routes"

Kemal::Session.config do |config|
  config.cookie_name = "session_id"
  config.secret = ENV["WIKI_SECRET"]? || Random::Secure.base64(64)
  config.gc_interval = 2.minutes # 2 minutes
end
