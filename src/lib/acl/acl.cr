# Permission levels of the Acl system
enum Acl::Perm
  # level 0. Cannot read, cannot write.
  None = 0

  # level 1. Can read, cannot write.
  Read = 1

  # level 3. Can read, can write.
  Write = 3
end

module Acl
  PERM = {
    none:  Acl::Perm::None,
    read:  Acl::Perm::Read,
    write: Acl::Perm::Write,
  }
end
