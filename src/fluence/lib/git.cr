require "./options"

module Fluence::Git
  extend self

  # Initialize the data repository (where the pages are stored).
  def init!
    Dir.mkdir_p Fluence::OPTIONS.basedir
    current = Dir.current
    Dir.cd Fluence::OPTIONS.basedir
    `git init .`
    Dir.cd current
  end
end

Fluence::Git.init!
