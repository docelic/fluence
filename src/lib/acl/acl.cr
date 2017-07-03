# Permission levels of the ACL system
enum Wikicr::ACL::Perm
  # level 0. Cannot read, cannot write.
  None = 0

  # level 1. Can read, cannot write.
  Read = 1

  # level 3. Can read, can write.
  Write = 3
end
