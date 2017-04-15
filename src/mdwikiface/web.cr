private def get_file_query(env)
  env.request.resource.gsub(/^\/\w+\//, "")
end

private def get_file_path(env)
  rpath = get_file_query(env)
  gpath = "./" + rpath + ".md"
  puts "File read: #{gpath}"
  gpath
end

error 404 do
  "Page not found"
end

error 403 do
  "Forbidden"
end

private def verify_request(env)
  return if env.request.resource == "/"
  file = get_file_path(env)
  begin
    rfile = File.real_path(file)
    chroot = Mdwikiface::ARG.basedir
    raise "Out of chroot" if chroot != rfile[0..(chroot.size - 1)]
    raise "Git directory" if "#{chroot}/.git" == rfile[0..(chroot.size + 4)]
  rescue
    env.response.status_code = 403
  end
end

VIEW_LAYOUT = "src/mdwikiface/views/layout.html.ecr"
VIEW_NEW    = "src/mdwikiface/views/new.html.ecr"

get "/" { |env| env.redirect "/show/README" }

get "/new" do |env|
  title = "New page"
  current_path = nil
  render "src/mdwikiface/views/new.html.slang", "src/mdwikiface/views/layout.html.slang"
end

before_get "/show/*" { |env| verify_request(env) }
get "/show/*" do |env|
  content = Markdown.to_html(File.read(get_file_path(env))) rescue env.response.status_code = 404
  current_path = get_file_query(env)
  title = File.basename current_path
  render "src/mdwikiface/views/layout.html.ecr"
end

before_get "/edit/*" { |env| verify_request(env) }
get "/edit/*" do |env|
end

before_get "/delete/*" { |env| verify_request(env) }
get "/delete/*" do |env|
end

before_post "/*" { |env| verify_request(env) }
post "/*" do |env|
  # .. create something ..
end

before_put "/*" { |env| verify_request(env) }
put "/*" do |env|
  # .. replace something ..
end

before_delete "/*" { |env| verify_request(env) }
delete "/*" do |env|
  # .. annihilate something ..
end
