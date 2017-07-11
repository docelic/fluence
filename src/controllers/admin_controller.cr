class AdminController < ApplicationController
  def users_show
    acl_permit! :write
    locals = {title: "Users admin", users: Wikicr::USERS.read!}
    render "users_show.slang"
  end

  def user_delete
    acl_permit! :write
    data = params
    Wikicr::USERS.read!
    Wikicr::USERS.delete(data["username"]).save!
    Wikicr::USERS.read!
    flash["success"] = "The user #{data["username"]} has been deleted."
    redirect_to "/admin/users"
  end

  def user_create
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

  def acls_show
    acl_permit! :read
    locals = {title: "Admin ACLs"}
    render "acls_show.slang"
  end

  def acl_update
    acl_permit! :write
    begin
      group = params["group"]
      path = params["path"]
      perm_str = params["change"]
      Wikicr::ACL.read!
      if perm_str == "delete"
        Wikicr::ACL[group].delete path
      else
        perm = Acl::PERM_STR[perm_str]
        acl = Wikicr::ACL[group][path] = perm
      end
      Wikicr::ACL.save!
    rescue err
      flash["danger"] = "Unable to process that: #{err.message}."
    end
    redirect_to "/admin/acls"
  end

  def acl_create
    acl_permit! :write
    group = params["group"]
    path = params["path"]
    perm_str = params["perm"]
    perm = Acl::PERM_STR[perm_str]
    Wikicr::ACL.read!
    Wikicr::ACL[group][path] = perm
    Wikicr::ACL.save!
    flash["success"] = "Add ACL #{group} :: #{path} :: #{perm}"
    redirect_to "/admin/acls"
  end
end
