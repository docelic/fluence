module Fluence
  class Options
    getter basedir : String

    def initialize
      @basedir = File.expand_path ENV.fetch("WIKI_DATA", "data"), Dir.current
      Dir.mkdir_p @basedir
    end
  end

  OPTIONS = Fluence::Options.new
end
