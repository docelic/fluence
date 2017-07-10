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

    acls.permitted?(u1, "/", Acl::Perm::Read).should be_true
    acls.permitted?(u1, "/tmp", Acl::Perm::Read).should be_true
    acls.permitted?(u1, "/tmp", Acl::Perm::Write).should be_false
    acls.permitted?(u1, "/tmp/protected", Acl::Perm::Read).should be_false
    acls.permitted?(u2, "/tmp/protected", Acl::Perm::Read).should be_true
  end

  it "test the paths matching" do
    Acl::Path.new("/*").acl_validates?("/a/test").should eq(true)
    Acl::Path.new("/a*").acl_validates?("/a/test").should eq(true)
    Acl::Path.new("/a/test*").acl_validates?("/a/test").should eq(true)
    Acl::Path.new("/a/test*").acl_validates?("/a/test/").should eq(true)
    Acl::Path.new("/a/test*").acl_validates?("/b/test").should eq(false)
    Acl::Path.new("/a/test*").acl_validates?("/a/other").should eq(false)
  end
end
