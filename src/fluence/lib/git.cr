require "../../../config/options"

module Fluence::Git
  extend self

  # Initialize the data repository (where the pages are stored).
  def init!
    Dir.mkdir_p Fluence::OPTIONS.datadir
    current = Dir.current
    Dir.cd Fluence::OPTIONS.datadir
    `git init .`
    Dir.cd current
  end
end

Fluence::Git.init!
