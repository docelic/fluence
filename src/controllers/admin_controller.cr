class AdminController < ApplicationController
  # get /admin/users
  def users_show
    acl_permit! :write
    users = Wikicr::USERS.load!
    render "users_show.slang"
  end

  # post /admin/users/create
  def user_create
    acl_permit! :write
    data = params
    begin
      user = Wikicr::USERS.register! data["username"], data["password"], data["groups"].split(",").map(&.strip)
      flash["success"] = "The user #{user.name} has been added."
    rescue err
      flash["danger"] = "Cannot register this account: #{err.message}."
    end
    redirect_to "/admin/users"
  end

  # post /admin/users/delete
  def user_delete
    acl_permit! :write
    data = params
    Wikicr::USERS.transaction! { |users| users.delete data["username"] }
    flash["success"] = "The user #{data["username"]} has been deleted."
    redirect_to "/admin/users"
  end

  # get /admin/acls
  def acls_show
    acl_permit! :read
    acls = Wikicr::ACL.load!
    render "acls_show.slang"
  end

  # post /admin/acls/create
  def acl_create
    acl_permit! :write
    group = params["group"]
    path = params["path"]
    perm_str = params["perm"]
    perm = Acl::PERM_STR[perm_str]
    Wikicr::ACL.transaction! do |acls|
      acls.add Acl::Group.new group if acls[group]?.nil?
      acls[group][path] = perm
    end
    flash["success"] = "ACL #{group} :: #{path} :: #{perm} has been added"
    redirect_to "/admin/acls"
  end

  # post /admin/acls/update
  def acl_update
    acl_permit! :write
    begin
      group = params["group"]
      path = params["path"]
      perm_str = params["change"]
      perm = Acl::PERM_STR[perm_str]
      Wikicr::ACL.transaction! do |acls|
        acls[group][path] = perm
      end
      flash["success"] = "ACL #{group} :: #{path} :: #{perm} has been updated."
    rescue err
      flash["danger"] = "Unable to process that: #{err.message}."
    end
    redirect_to "/admin/acls"
  end

  # post /admin/acls/delete
  def acl_delete
    acl_permit! :write
    group = params["group"]
    path = params["path"]
    Wikicr::ACL.transaction! do |acls|
      acls[group].delete path
    end
    flash["success"] = "ACL #{group} :: #{path} has been deleted."
    redirect_to "/admin/acls"
  end
end
