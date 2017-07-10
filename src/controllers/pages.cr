private def fetch_params(env)
  path = env.params.url["path"]
  page = Wikicr::Page.new path
  {
    :title => page.title,
    :path  => page.url,
    :page  => page,
  }
end

get "/pages/search" do |env|
  # user_must_be_logged!(env)
  query = env.params.query["q"]
  # TODO: a real search
  env.redirect query.empty? ? "/pages" : query
end

get "/pages/" do |env|
  env.redirect("/pages/home")
end

get "/pages/*path" do |env|
  acl_permit! :read
  locals = fetch_params(env)
  locals[:body] = (locals[:page].as(Wikicr::Page).read(current_user(env)) rescue "")
  if (env.params.query["edit"]?) || !locals[:page].as(Wikicr::Page).exists?(current_user(env))
    render_pages(edit)
  else
    body_html = Markdown.to_html(locals[:body].as(String))
    Wikicr::ACL.read!
    groups_read = Wikicr::ACL.groups_having(locals[:path].as(String), Acl::Perm::Read, true)
    groups_write = Wikicr::ACL.groups_having(locals[:path].as(String), Acl::Perm::Write, true)
    locals = locals.merge({
      :body_html    => body_html,
      :groups_read  => groups_read.join(","),
      :groups_write => groups_write.join(","),
    })
    render_pages(show)
  end
end

post "/pages/*path" do |env|
  acl_permit! :write
  locals = fetch_params(env)
  if (env.params.body["body"]?.to_s.empty?)
    locals[:page].as(Wikicr::Page).delete(current_user(env)) rescue nil
    env.redirect "/pages/"
  else
    locals[:page].as(Wikicr::Page).write env.params.body["body"], current_user(env)
    env.redirect "/pages/#{locals[:path]}"
  end
end
