require "yaml"

require "./acl"

# The Group is identified by a *name* and has *permissions* on a set of paths.
# It is used by `Groups`.
# NOTE: I did not used Hash().new(default) because it is annoying with passing the permissions in the constructor
class Acl::Group
  # getter name : String
  # getter permissions : Hash(String, Acl::Perm)
  # property default : Acl::Perm

  YAML.mapping(
    name: String,
    permissions: Hash(String, Acl::Perm),
    default: Acl::Perm
  )

  # Create a new named Group with optional parameters.
  #
  # - *name* is the name of the group (arbitrary `String`).
  # - *permissions* is a hash of ``{"path" => `Perm`}``.
  # - *default* is the value used for every path not defined in the *permissions*.
  #
  # ```
  # guest = Acl::Group.new(name: "guest", default: Acl::Perm::None, permissions: {"/public" => Acl::Perm::Read})
  # user = Acl::Group.new(name: "user", default: Acl::Perm::Read, permissions: {"/protected" => Acl::Perm::None})
  # admin = Acl::Group.new(name: "admin", default: Acl::Perm::Write)
  # ```
  def initialize(@name,
                 @permissions = Hash(String, Acl::Perm).new,
                 @default : Acl::Perm = Acl::Perm::None)
  end

  # Check if the group as the `Acl::Perm` required to have access to a given path.
  #
  # - *path* is the path that must be checked
  # - *access* is the minimal `Acl::Perm` required for a given operation
  # ```
  # guest = Acl::Group.new(name: "guest", default: Acl::Perm::None, permissions: {"/public" => Acl::Perm::Read})
  # guest.permitted "/public", Acl::Perm::Read  # => true
  # guest.permitted "/public", Acl::Perm::Write # => false
  # guest.permitted "/other", Acl::Perm::Read   # => false
  # ```
  def permitted?(path : String, access : Acl::Perm) : Bool
    permissions.fetch(path, default).to_i >= access.to_i
  end

  # def if_permitted(path : String, access : Acl::Perm) : Bool
  #   yield if permitted? path, access
  # end
end
