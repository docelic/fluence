require "./options"

module Wikicr::Git
  extend self

  # Initialize the data repository (where the pages are stored).
  def init!
    Dir.mkdir_p Wikicr::OPTIONS.basedir
    current = Dir.current
    Dir.cd Wikicr::OPTIONS.basedir
    `git init .`
    Dir.cd current
  end
end

Wikicr::Git.init!
