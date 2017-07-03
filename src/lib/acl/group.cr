require "./acl"

# note: I did not used Hash().new(default) because it is annoying with passing the permissions in the constructor
class Wikicr::ACL::Group
  getter name : String
  getter permissions : Hash(String, ACL::Perm)
  property default : ACL::Perm

  def initialize(@name,
                 @permissions = Hash(String, ACL::Perm).new,
                 @default : ACL::Perm = ACL::Perm::None)
  end

  def permitted?(path : String, access : ACL::Perm) : Bool
    permissions.fetch(path, default).to_i >= access.to_i
  end
end
