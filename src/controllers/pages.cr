require "markdown"

before_all do |env|
  # env.session = Session.new(env.cookies)
end

private def fetch_params(env)
  path = env.params.url["path"]
  {
    path:         path,                   # basic path from the params unmodified
    display_path: path,                   # TODO: clean the path
    title:        path.split("/").last,   # keep only the name of the file
    page:         Wikicr::Page.new(path), # page handler
  }
  # file_path:    Wikicr::Page.new(path).jail.file, # jail the path (safety)
end

get "/pages/search" do |env|
  user_must_be_logged!(env)
  query = env.params.query["q"]
  # TODO: a real search
  env.redirect query.empty? ? "/pages" : query
end

get "/pages/" do |env|
  user_must_be_logged!(env)
  env.redirect("/pages/home")
end

get "/pages/*path" do |env|
  user_must_be_logged!(env)
  locals = fetch_params(env).to_h
  locals[:body] = (locals[:page].as(Wikicr::Page).read(current_user(env)) rescue "")
  if (env.params.query["edit"]?) || !locals[:page].as(Wikicr::Page).exists?(current_user(env))
    render_page(edit)
  else
    locals[:body_html] = Markdown.to_html(locals[:body].as(String))
    render_page(show)
  end
end

post "/pages/*path" do |env|
  user_must_be_logged!(env)
  locals = fetch_params(env).to_h
  if (env.params.body["body"]?.to_s.empty?)
    locals[:page].as(Wikicr::Page).delete(current_user(env)) rescue nil
    env.redirect "/pages/"
  else
    locals[:page].as(Wikicr::Page).write env.params.body["body"], current_user(env)
    env.redirect "/pages/#{locals[:path]}"
  end
end
