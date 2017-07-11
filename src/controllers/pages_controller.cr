def add_page(page, stack = [] of String)
  String.build do |str|
    Slang.embed("src/views/pages/sitemap.directory.slang", "str")
  end
end

class PagesController < ApplicationController
  def sitemap
    acl_permit! :read
    locals = {title: "sitemap", pages: Wikicr::FileTree.build(Wikicr::OPTIONS.basedir)}
    render "sitemap.slang"
  end

  def index
    redirect_to "/pages/home"
  end

  private def fetch_params
    path = params["path"]
    page = Wikicr::Page.new path
    {
      :title => page.title,
      :path  => page.url,
      :page  => page,
    }
  end

  def search
    # user_must_be_logged!
    query = params["q"]
    # TODO: a real search
    redirect_to query.empty? ? "/pages" : query
  end

  def home
    redirect_to("/pages/home")
  end

  def show
    acl_permit! :read
    locals = fetch_params
    page = locals[:page].as(Wikicr::Page)
    locals[:body] = (page.read(current_user) rescue "")
    if (params["edit"]?) || !page.exists?(current_user)
      flash["info"] = "The page #{locals[:path]} does not exist yet."
      acl_permit! :write
      render "edit.slang"
    else
      body_html = Markdown.to_html(locals[:body].as(String))
      Wikicr::ACL.read!
      groups_read = Wikicr::ACL.groups_having(page.real_url, Acl::Perm::Read, true)
      groups_write = Wikicr::ACL.groups_having(page.real_url, Acl::Perm::Write, true)
      locals = locals.merge({
        :body_html    => body_html,
        :groups_read  => groups_read.join(","),
        :groups_write => groups_write.join(","),
      })
      render "show.slang"
    end
  end

  def update
    acl_permit! :write
    locals = fetch_params
    if (params["body"]?.to_s.empty?)
      locals[:page].as(Wikicr::Page).delete(current_user) rescue nil
      flash["info"] = "The page #{locals[:path]} has been deleted."
      redirect_to "/pages/"
    else
      locals[:page].as(Wikicr::Page).write params["body"], current_user
      flash["info"] = "The page #{locals[:path]} has been updated."
      redirect_to "/pages/#{locals[:path]}"
    end
  end

  def admin
    acl_permit! :write
    data = params
    page = Wikicr::Page.new params["path"]

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
    flash["info"] = "The permissions of the page #{page.url} have been updated"

    redirect_to page.real_url
  end
end
