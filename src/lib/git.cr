require "./options"

module Wikicr::Git
  extend self

  def init!
    Dir.mkdir_p Wikicr::OPTIONS.basedir
  end
end

Wikicr::Git.init!
