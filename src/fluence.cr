require "markd"
require "yaml"
require "json"
require "kemal"
require "kemal-session"
require "kemal-flash"
require "kilt/slang"

require "./version"
require "./controllers/application_controller"
require "./_init"
require "../config/routes"

require "../config/application"

Kemal.config.host_binding = Fluence::OPTIONS.host
Kemal.config.port = Fluence::OPTIONS.port

Kemal.run
