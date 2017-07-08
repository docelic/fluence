# Admin
get "/users/admin" do |env|
  user_must_be_admin!
  locals = {title: "Users admin", users: Wikicr::USERS.read!}
  render_users_admin(admin)
end

# post "/users/admin" do |env|
#   user_must_be_admin!
#   data = env.params.body
#   env.redirect "/users/admin"
# end

post "/users/admin/delete" do |env|
  user_must_be_admin!
  data = env.params.body
  Wikicr::USERS.read!
  Wikicr::USERS.delete(data["username"]).save!
  puts "TRY TO DELETE #{data["username"]}"
  Wikicr::USERS.read!
  env.redirect "/users/admin"
end

post "/users/admin/register" do |env|
  user_must_be_admin!
  data = env.params.body
  user = Wikicr::USERS.register! data["username"], data["password"], data["groups"].split(",").map(&.strip)
  env.redirect "/users/admin"
end
