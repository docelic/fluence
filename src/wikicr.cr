require "markdown"
# require "option_parser"

require "kemal"
require "kemal-session"
require "kilt/slang"
# require "crystal-libgit2"
require "markdown"

require "./version"
require "./lib/init"
require "./controllers"

puts "Wiki is written on #{Wikicr::OPTIONS.basedir}"
Kemal.run
