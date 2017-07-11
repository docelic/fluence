def add_page(page, stack = [] of String)
  String.build do |str|
    Slang.embed("src/views/pages/sitemap.directory.slang", "str")
  end
end

class PagesController < ApplicationController
  private def fetch_params
    path = params["path"]
    page = Wikicr::Page.new url: path, read_title: true
    {
      :title => page.title,
      :path  => page.url,
      :page  => page,
    }
  end

  # get /sitemap
  def sitemap
    acl_permit! :read
    locals = {title: "sitemap", pages: Wikicr::FileTree.build(Wikicr::OPTIONS.basedir)}
    render "sitemap.slang"
  end

  # get /pages
  def index
    redirect_to "/pages/home"
  end

  # get /pages/search?q=
  def search
    # user_must_be_logged!
    query = params["q"]
    page = Wikicr::Page.new(query)
    # TODO: a real search
    redirect_to query.empty? ? "/pages" : page.real_url
  end

  # get /pages/*path
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
      body_html = Markdown.to_html locals[:body].as(String)
      Wikicr::ACL.load!
      groups_read = Wikicr::ACL.groups_having_any_access_to page.real_url, Acl::Perm::Read, true
      groups_write = Wikicr::ACL.groups_having_any_access_to page.real_url, Acl::Perm::Write, true
      locals = locals.merge({
        :body_html    => body_html,
        :groups_read  => groups_read,
        :groups_write => groups_write,
      })
      render "show.slang"
    end
  end

  # post /pages/*path
  def update
    acl_permit! :write
    locals = fetch_params
    if (params["body"]?.to_s.empty?)
      locals[:page].as(Wikicr::Page).delete(current_user) rescue nil
      flash["info"] = "The page #{locals[:path]} has been deleted."
      Wikicr::PAGES.transaction! { |index| index.delete locals[:page].as(Wikicr::Page) }
      redirect_to "/pages/"
    else
      locals[:page].as(Wikicr::Page).write params["body"], current_user
      flash["info"] = "The page #{locals[:path]} has been updated."
      Wikicr::PAGES.transaction! { |index| index.add locals[:page].as(Wikicr::Page) }
      redirect_to "/pages/#{locals[:path]}"
    end
  end
end
