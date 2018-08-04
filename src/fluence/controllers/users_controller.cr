class UsersController < ApplicationController
  # get /users/login
  def login
    acl_permit! :read
    render "login.slang"
  end

  # post /users/login
  def login_validates
    acl_permit! :write
    user = Fluence::USERS.auth! params.body["username"].to_s, params.body["password"].to_s
    # TODO: make a notification
    if user.nil?
      flash["danger"] = "User or password doesn't match."
      redirect_to "/users/login"
    else
      flash["success"] = "You are now logged in as user '#{user.name}'."
      session.string("user.name", user.name)
      set_login_cookies_for(user.name)
      redirect_to "/pages/home"
    end
  end

  # get /users/register
  def register
    acl_permit! :read
    render "register.slang"
  end

  # post /users/register
  def register_validates
    acl_permit! :write
    # TODO: make a notification
    begin
      user = Fluence::USERS.register! params.body["username"].to_s, params.body["password"].to_s
      flash["success"] = "You are now registered with the username '#{user.name}'. Please log in."
      redirect_to "/users/login"
    rescue err
      flash["danger"] = "Cannot register this account: #{err.message}."
      redirect_to "/users/register"
    end
  end
end
