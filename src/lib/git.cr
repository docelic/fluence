require "./options"

module Wikicr::Git
  extend self

  def init!
    Dir.mkdir_p Wikicr::OPTIONS.basedir
    current = Dir.current
    Dir.cd Wikicr::OPTIONS.basedir
    `git init .`
    Dir.cd current
  end
end

Wikicr::Git.init!
