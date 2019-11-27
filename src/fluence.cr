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

require "../config/application"

Kemal.config.host_binding = Fluence::OPTIONS.host
Kemal.config.port = Fluence::OPTIONS.port

Kemal.run
