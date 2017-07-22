require "./acl/**"

module Acl
  PERM = {
    none:  Acl::Perm::None,
    read:  Acl::Perm::Read,
    write: Acl::Perm::Write,
  }

  PERM_STR = {
    "none"  => Acl::Perm::None,
    "read"  => Acl::Perm::Read,
    "write" => Acl::Perm::Write,
  }
end
