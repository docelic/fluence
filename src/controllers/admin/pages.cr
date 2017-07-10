# Admin
post "/admin/pages/*path" do |env|
  acl_permit! :write
  data = env.params.body
  path = env.params.url["path"]

  Wikicr::ACL.read!
  # Set the new permissions
  groups = data["groups"].strip.split(",").map(&.strip)
  groups.delete ""
  pp data
  if data["change"] == "read"
    Wikicr::ACL.clear_permissions_of(path, Acl::Perm::Read)
    Wikicr::ACL.add_permissions_to(path, groups, Acl::Perm::Read)
    Wikicr::GUEST[path] = Acl::Perm::None unless groups.empty?
  elsif data["change"] == "write"
    Wikicr::ACL.clear_permissions_of(path, Acl::Perm::Write)
    Wikicr::ACL.add_permissions_to(path, groups, Acl::Perm::Write)
  end
  Wikicr::ACL.save!

  env.redirect "/pages/#{path}"
end
