class Wikicr::Options
  getter basedir : String

  def initialize
    @basedir = File.expand_path "data", Dir.current
    Dir.mkdir_p(@basedir) rescue nil
  end
end

module Wikicr
  OPTIONS = Wikicr::Options.new
  # REPO    = Libgitit2.open_repository(OPTIONS.basedir)
end
