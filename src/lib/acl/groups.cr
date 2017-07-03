require "./acl"
require "./group"
require "./entity"

# The Groups is used to handle a set of uniq `Group`, by *name*.
class Wikicr::ACL::Groups
  @groups : Hash(String, ACL::Group)

  # ```
  # acls = ACL::Groups.new
  # g1 = ACL::Group.new(name: "user", default: ACL::Perm::Read, permissions: {"/tmp/protected" => ACL::Perm::None})
  # g2 = ACL::Group.new(name: "admin", default: ACL::Perm::Write)
  # acls.add g1
  # acls.add g2
  # ```
  def initialize
    @groups = Hash(String, ACL::Group).new
  end

  # Check if an `Entity` has a group with the required permissions to operate.
  #
  # ```
  # acls = Groups.new ...
  # user = User.new ...
  # acls.permitted?(user, "/my/path", Perm::Read)
  # ```
  def permitted?(entity : ACL::Entity, path : String, access : ACL::Perm)
    entity.groups.map do |group|
      @groups[group].permitted?(path, access)
    end.reduce(false) { |l, r| l | r }
  end

  # def if_permitted(entity : ACL::Entity, path : String, access : ACL::Perm)
  #   yield block if permitted? entity, path, access
  # end

  def add(group : String)
    @groups[group] = Group.new(group)
  end

  def add(group : ACL::Group)
    @groups[group.name] = group
  end

  def delete(group : String)
    @groups.delete(group)
  end

  def delete(group : ACL::Group)
    @groups.delete(group.name)
  end

  def [](group : String) : ACL::Group
    @groups[group]
  end

  def [](group : ACL::Group) : ACL::Group
    @groups[group.name]
  end

  def []?(group : String) : ACL::Group?
    (@groups[group]?)
  end

  def []?(group : ACL::Group) : ACL::Group?
    (@groups[group.name]?)
  end
end
