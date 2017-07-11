require "markdown"
require "yaml"

require "./version"
require "./lib/init"

require "amber"
require "./controllers/**"
require "./mailers/**"
require "./models/**"
require "./views/**"
require "../config/*"

Amber::Server.instance.run
