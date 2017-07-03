require "./acl"
require "./group"
require "./entity"

# The Groups is used to handle a set of uniq `Group`, by *name*.
class Wikicr::ACL::Groups
  @groups : Hash(String, ACL::Group)

  def initialize
    @groups = Hash(String, ACL::Group).new
  end

  # Check if an `Entity` has a group with the required permissions to operate
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
