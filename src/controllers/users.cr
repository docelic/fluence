module Wikicr
  Dir.mkdir("meta") rescue nil
  File.touch("meta/users") rescue nil
  USERS = Wikicr::Users.new("meta/users")
end

private def fetch_params(env)
  {
    username: (env.params.body["username"]?),
    password: (env.params.body["password"]?),
  }
end

get "/users/login" do |env|
  locals = {title: "Login"}
  render_user(login)
end

post "/users/login" do |env|
  locals = fetch_params(env)
  user = Wikicr::USERS.auth! locals[:username].to_s, locals[:password].to_s
  # TODO: make a notification
  if user.nil?
    env.redirect "/users/login"
  else
    env.redirect "/pages"
  end
end

get "/users/register" do |env|
  locals = {title: "Register"}
  render_user(register)
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
