module Wikicr
  class Options
    getter basedir : String

    def initialize
      @basedir = File.expand_path ENV.fetch("WIKI_DATA", "data"), Dir.current
      Dir.mkdir_p @basedir rescue nil
    end
  end

  OPTIONS = Wikicr::Options.new
end
