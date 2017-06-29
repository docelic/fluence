require "markdown"
#require "option_parser"

require "kemal"
require "kilt/slang"
require "crystal-libgit2"

module Mdwikiface
  class Options
    getter basedir : String

    def initialize
      @basedir = Dir.current

      #OptionParser.parse! do |parser|
      #  parser.banner = "Usage: mdwikiface [arguments]"
      #  parser.on("-b=PATH", "--basedir=PATH", "Directory where the wiki must start (default: #{@basedir})") { |path| @basedir = path }
      #  parser.on("-h", "--help", "Show this help") { puts parser; exit }
      #end
    end
  end

  ARG  = Options.new
  REPO = Libgitit2.open_repository(ARG.basedir)
end

require "./mdwikiface/*"

puts "Wiki is written on #{Mdwikiface::ARG.basedir}"
Kemal.run
