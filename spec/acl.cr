include Wikicr

describe Acl do
  it "test the users permissions" do
    acls = Acl::Groups.new
    g1 = Acl::Group.new(
      name: "user",
      default: Acl::Perm::Read,
      permissions: {
        "/tmp/protected" => Acl::Perm::None,
        "/tmp/write/*"   => Acl::Perm::Write,
      })
    g2 = Acl::Group.new(
      name: "admin",
      default: Acl::Perm::Write)
    acls.add g1
    acls.add g2
    u1 = User.new "u1", "", %w(user)
    u2 = User.new "u2", "", %w(user admin)

    acls.permitted?(u1, "/", Acl::Perm::Read).should be_true
    acls.permitted?(u1, "/tmp", Acl::Perm::Read).should be_true
    acls.permitted?(u1, "/tmp", Acl::Perm::Write).should be_false
    acls.permitted?(u1, "/tmp/protected", Acl::Perm::Read).should be_false
    acls.permitted?(u2, "/tmp/protected", Acl::Perm::Read).should be_true
  end
end
