require "./acl"
require "./group"
require "./entity"

class Wikicr::ACL::Groups
  @groups : Hash(String, ACL::Group)

  def initialize
    @groups = Hash(String, ACL::Group).new
  end

  def permitted?(entity : ACL::Entity, path : String, access : ACL::Perm)
    entity.groups.map do |group|
      @groups[group].permitted?(path, access)
    end.reduce(false) { |l, r| l | r }
  end

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
