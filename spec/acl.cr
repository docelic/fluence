include Wikicr

describe ACL do
  it "test the users permissions" do
    acls = ACL::Groups.new
    g1 = ACL::Group.new(name: "user", default: ACL::Perm::Read, permissions: {"/tmp/protected" => ACL::Perm::None})
    g2 = ACL::Group.new(name: "admin", default: ACL::Perm::Write)
    acls.add g1
    acls.add g2
    u1 = User.new "u1", "", %w(user)
    u2 = User.new "u2", "", %w(user admin)

    acls.permitted?(u1, "/", ACL::Perm::Read).should be_true
    acls.permitted?(u1, "/tmp", ACL::Perm::Read).should be_true
    acls.permitted?(u1, "/tmp", ACL::Perm::Write).should be_false
    acls.permitted?(u1, "/tmp/protected", ACL::Perm::Read).should be_false
    acls.permitted?(u2, "/tmp/protected", ACL::Perm::Read).should be_true
  end
end
