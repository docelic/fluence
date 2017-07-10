require "yaml"

require "./acl"
require "./group"
require "./entity"

# The Groups is used to handle a set of uniq `Group`, by *name*.
class Acl::Groups
  # @groups : Hash(String, Acl::Group)
  # property file : String

  YAML.mapping(
    file: String,
    groups: Hash(String, Acl::Group)
  )

  # ```
  # acls = Acl::Groups.new
  # g1 = Acl::Group.new(name: "user", default: Acl::Perm::Read, permissions: {"/tmp/protected" => Acl::Perm::None})
  # g2 = Acl::Group.new(name: "admin", default: Acl::Perm::Write)
  # acls.add g1
  # acls.add g2
  # ```
  def initialize(@file)
    @groups = Hash(String, Acl::Group).new
  end

  def save!
    File.write(@file, to_yaml)
    self
  end

  # Read the file and erase the content, skip if the file does not exists
  def read!
    return self unless File.exists? @file
    groups = Acl::Groups.read(@file)
    @file = groups.file
    @groups = groups.groups
    self
  end

  def self.read(file : String)
    Acl::Groups.from_yaml(File.read file)
  end

  # Check if an `Entity` has a group with the required permissions to operate.
  #
  # ```
  # acls = Groups.new ...
  # user = User.new ...
  # acls.permitted?(user, "/my/path", Perm::Read)
  # ```
  def permitted?(entity : Acl::Entity, path : String, access : Acl::Perm)
    entity.groups.map do |group|
      @groups[group].permitted?(path, access)
    end.reduce(false) { |l, r| l | r }
  end

  # def if_permitted(entity : Acl::Entity, path : String, access : Acl::Perm)
  #   yield block if permitted? entity, path, access
  # end

  def add(group : String)
    @groups[group] = Group.new(group)
  end

  def add(group : Acl::Group)
    @groups[group.name] = group
  end

  def delete(group : String)
    @groups.delete(group)
  end

  def delete(group : Acl::Group)
    @groups.delete(group.name)
  end

  def [](group : String) : Acl::Group
    @groups[group]
  end

  def [](group : Acl::Group) : Acl::Group
    @groups[group.name]
  end

  def []?(group : String) : Acl::Group?
    (@groups[group]?)
  end

  def []?(group : Acl::Group) : Acl::Group?
    (@groups[group.name]?)
  end

  def groups_having(path : String) : Hash(String, Acl::Perm)
    @groups.map do |_, group|
      {group.name, @groups[group.name].permissions[path]?}
    end.to_h.compact
  end
end
