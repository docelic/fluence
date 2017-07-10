require "tempfile"

describe Acl do
  it "test the users permissions" do
    acls = Acl::Groups.new Tempfile.new("spec").to_s
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
    u1 = Wikicr::User.new "u1", "", %w(user)
    u2 = Wikicr::User.new "u2", "", %w(user admin)

    # simple
    acls.permitted?(u1, "/", Acl::Perm::Read).should be_true
    acls.permitted?(u1, "/tmp", Acl::Perm::Read).should be_true
    acls.permitted?(u1, "/tmp", Acl::Perm::Write).should be_false
    acls.permitted?(u1, "/tmp/protected", Acl::Perm::Read).should be_false
    acls.permitted?(u2, "/tmp/protected", Acl::Perm::Read).should be_true

    # matching
    acls.permitted?(u1, "/tmp/write/test", Acl::Perm::Read).should be_true
    acls.permitted?(u1, "/tmp/write/test", Acl::Perm::Write).should be_true
  end

  it "test the paths matching" do
    Acl::Path.new("/*").acl_match?("/a/test").should eq(true)
    Acl::Path.new("/a*").acl_match?("/a/test").should eq(true)
    Acl::Path.new("/a/test*").acl_match?("/a/test").should eq(true)
    Acl::Path.new("/a/test*").acl_match?("/a/test/").should eq(true)
    Acl::Path.new("/a/test*").acl_match?("/b/test").should eq(false)
    Acl::Path.new("/a/test*").acl_match?("/a/other").should eq(false)
  end

  it "groups having" do
    acls = Acl::Groups.new Tempfile.new("spec").to_s
    acls.add "guest"
    acls.add "admin"
    acls["guest"]["/*"] = Acl::Perm::Read
    acls["guest"]["/write/*"] = Acl::Perm::Write
    acls["guest"]["/write/admin"] = Acl::Perm::Read
    acls["admin"]["/*"] = Acl::Perm::Write
    acls.groups_having("/", Acl::Perm::Read).should eq(["guest", "admin"])
    acls.groups_having("/", Acl::Perm::Write).should eq(["admin"])
    acls.groups_having("/write", Acl::Perm::Write).should eq(["admin"])
    acls.groups_having("/write/anypage", Acl::Perm::Write).should eq(["guest", "admin"])
    acls.groups_having("/write/admin", Acl::Perm::Write).should eq(["admin"])
  end
end
