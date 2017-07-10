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
    permissions: Hash(Acl::Path, Acl::Perm),
    default: Acl::Perm
  )

  # Create a new named Group with optional parameters.
  #
  # - *name* is the name of the group (arbitrary `String`).
  # - *permissions* is a hash of ``{Acl::Path.new("path") => `Perm`}``.
  # - *default* is the value used for every path not defined in the *permissions*.
  #
  # ```
  # guest = Acl::Group.new(name: "guest", default: Acl::Perm::None, permissions: {Acl::Path.new "/public" => Acl::Perm::Read})
  # user = Acl::Group.new(name: "user", default: Acl::Perm::Read, permissions: {Acl::Path.new "/protected" => Acl::Perm::None})
  # admin = Acl::Group.new(name: "admin", default: Acl::Perm::Write)
  # ```
  def initialize(@name,
                 @permissions = Hash(Acl::Path, Acl::Perm).new,
                 @default : Acl::Perm = Acl::Perm::None)
  end

  # ```
  # guest = Acl::Group.new(name: "guest", default: Acl::Perm::None, permissions: {"/public" => Acl::Perm::Read})
  # user = Acl::Group.new(name: "user", default: Acl::Perm::Read, permissions: {"/protected" => Acl::Perm::None})
  # admin = Acl::Group.new(name: "admin", default: Acl::Perm::Write)
  # ```
  def initialize(@name,
                 permissions = Hash(String, Acl::Perm).new,
                 @default : Acl::Perm = Acl::Perm::None)
    @permissions = permissions.map { |k, v| {Acl::Path.new(k), v} }.to_h
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
    @permissions.fetch(path, default).to_i >= access.to_i
    matched_permissions = @permissions.select { |pe, _| pe.acl_match?(path) }
    if matched_permissions.empty?
      default.to_i >= access.to_i
    else
      matched_permissions.any? { |_, acl| acl.to_i >= access.to_i }
    end
  end

  # Same than Path[String]? but raises KeyError if not found
  def [](path : String) : Acl::Perm
    acl = self[path]?
    raise KeyError.new "No match for path `#{path}`" if acl.nil?
    acl
  end

  def []=(path : String, acl : Acl::Perm)
    replace = @permissions.find{|ppath, _| ppath == path}
    if replace
      @permissions[replace[0]] = acl
    else
      @permissions[Acl::Path.new(path)] = acl
    end
  end

  # Tries to match the *path* with the permissions of this group.
  # If select every matching path and get the maximum permission among them.
  def []?(path : String) : Acl::Perm?
    founds = @permissions.select { |ppath, pgroup| ppath.acl_match?(path) }
    return nil if founds.empty?
    found_min_size = founds.reduce { |left, right| left[0].size >= right[0].size ? left : right}
    found_min_size[1]
  end

  def delete(path : String)
    @permissions.delete_if { |current_path| current_path.to_s == path }
    self
  end
end
