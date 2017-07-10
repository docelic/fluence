# Admin
post "/admin/pages/*path" do |env|
  acl_permit! :write
  data = env.params.body
  page = Wikicr::Page.new env.params.url["path"]

  Wikicr::ACL.read!
  # Set the new permissions
  groups = data["groups"].strip.split(",").map(&.strip)
  groups.delete ""
  if data["change"] == "read"
    Wikicr::ACL.clear_permissions_of(page.real_url, Acl::Perm::Read)
    Wikicr::ACL.add_permissions_to(page.real_url, groups, Acl::Perm::Read)
    Wikicr::GUEST[page.real_url] = Acl::Perm::None unless groups.empty?
  elsif data["change"] == "write"
    Wikicr::ACL.clear_permissions_of(page.real_url, Acl::Perm::Write)
    Wikicr::ACL.add_permissions_to(page.real_url, groups, Acl::Perm::Write)
  end
  Wikicr::ACL.save!

  env.redirect page.real_url
end
