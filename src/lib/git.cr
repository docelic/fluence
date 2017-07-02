require "./options"

module Wikicr::Git
  Dir.mkdir_p Wikicr::OPTIONS.basedir
  REPO = Pointer(LibGit2::X_Repository).null
  # todo: check result
  LibGit2.repository_init(REPO, Wikicr::OPTIONS.basedir, 0)
end
