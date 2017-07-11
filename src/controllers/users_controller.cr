private def fetch_params
  {
    username: (params["username"]?),
    password: (params["password"]?),
  }
end

class UsersController < ApplicationController
  # Login
  def login
    acl_permit! :read
    locals = {title: "Login"}
    render "login.slang"
  end

  def login_validates
    acl_permit! :write
    user = Wikicr::USERS.auth! params["username"].to_s, params["password"].to_s
    # TODO: make a notification
    if user.nil?
      flash["danger"] = "User or password doesn't match."
      redirect_to "/users/login"
    else
      flash["success"] = "You are connected!"
      session["username"] = user.name
      redirect_to "/pages"
    end
  end

  # Register
  def register
    acl_permit! :read
    locals = {title: "Register"}
    render "register.slang"
  end

  def register_validates
    acl_permit! :write
    # TODO: make a notification
    begin
      user = Wikicr::USERS.register! params["username"].to_s, params["password"].to_s
      flash["success"] = "You are registrated under the username #{user.name}. You can connect now."
      redirect_to "/users/login"
    rescue err
      flash["danger"] = "Cannot register this account: #{err.message}."
      redirect_to "/users/register"
    end
  end

  # Admin
  def admin
    acl_permit! :write
    locals = {title: "Users admin", users: Wikicr::USERS.read!}
    render "admin.slang"
  end

  def admin_delete
    acl_permit! :write
    data = params
    Wikicr::USERS.read!
    Wikicr::USERS.delete(data["username"]).save!
    Wikicr::USERS.read!
    flash["success"] = "The user #{data["username"]} has been deleted."
    redirect_to "/admin/users"
  end

  def admin_register
    acl_permit! :write
    data = params
    begin
      user = Wikicr::USERS.register! data["username"], data["password"], data["groups"].split(",").map(&.strip)
      flash["success"] = "The user #{user.name} has been added."
    rescue err
      flash["danger"] = "Cannot register this account: #{err.message}."
      redirect_to "/admin/users"
    end
  end
end
