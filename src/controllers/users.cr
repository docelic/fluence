module Wikicr
  Dir.mkdir_p("meta")
  File.touch("meta/users")
  USERS = Wikicr::Users.new("meta/users")
end

private def fetch_params(env)
  {
    username: (env.params.body["username"]?),
    password: (env.params.body["password"]?),
  }
end

require "./users/*"

# Login
get "/users/login" do |env|
  locals = {title: "Login"}
  render_users(login)
end

post "/users/login" do |env|
  locals = fetch_params(env)
  user = Wikicr::USERS.auth! locals[:username].to_s, locals[:password].to_s
  # TODO: make a notification
  if user.nil?
    env.redirect "/users/login"
  else
    env.session.string("username", user.name)
    env.redirect "/pages"
  end
end

# Registration
get "/users/register" do |env|
  locals = {title: "Register"}
  render_users(register)
end

post "/users/register" do |env|
  locals = fetch_params(env)
  # TODO: make a notification
  begin
    user = Wikicr::USERS.register! locals[:username].to_s, locals[:password].to_s
    env.redirect "/users/login"
  rescue
    env.redirect "/users/register"
  end
end
