# Admin
get "/admin/users" do |env|
  acl_permit! :write
  locals = {title: "Users admin", users: Wikicr::USERS.read!}
  render_admin(users)
end

# post "/admin/users" do |env|
#   user_must_be_admin!
#   data = env.params.body
#   env.redirect "/admin/users"
# end

post "/admin/users/delete" do |env|
  acl_permit! :write
  data = env.params.body
  Wikicr::USERS.read!
  Wikicr::USERS.delete(data["username"]).save!
  Wikicr::USERS.read!
  env.redirect "/admin/users"
end

post "/admin/users/register" do |env|
  acl_permit! :write
  data = env.params.body
  user = Wikicr::USERS.register! data["username"], data["password"], data["groups"].split(",").map(&.strip)
  env.redirect "/admin/users"
end
