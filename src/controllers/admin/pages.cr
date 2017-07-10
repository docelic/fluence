# Admin
post "/admin/pages/*path" do |env|
  acl_permit! :write
  data = env.params.body
  path = env.params.url["path"]

  Wikicr::ACL.read!
  # Set the new permissions
  if data["change"] == "read"
    data["groups"].split(",").map(&.strip).each do |group|
      Wikicr::ACL.add group if Wikicr::ACL[group]?.nil?
      Wikicr::ACL[group].permissions[path] = Acl::Perm::Read
    end
  elsif data["change"] == "write"
    data["groups"].split(",").map(&.strip).each do |group|
      Wikicr::ACL.add group if Wikicr::ACL[group]?.nil?
      Wikicr::ACL[group].permissions[path] = Acl::Perm::Write
    end
  end
  Wikicr::ACL.save!

  env.redirect "/pages/#{path}"
end
