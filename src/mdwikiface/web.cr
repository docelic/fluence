private def get_file_path(env)
  "." + env.request.resource + ".md"
end

error 404 do
  "Page not found"
end

error 403 do
  "Forbidden"
end

before_all do |env|
  file = get_file_path(env)
  begin
    rfile = File.real_path(file)
    chroot = Dir.current
    raise "Out of chroot" if chroot != rfile[0..(chroot.size - 1)]
    raise "Git directory" if "#{chroot}/.git" == rfile[0..(chroot.size + 4)]
  rescue
    env.response.status_code = 403
  end
end

get "/*" do |env|
  Markdown.to_html(File.read(get_file_path(env))) rescue env.response.status_code = 404
end

post "/*" do |env|
  # .. create something ..
end

put "/*" do |env|
  # .. replace something ..
end

patch "/*" do |env|
  # .. modify something ..
end

delete "/*" do |env|
  # .. annihilate something ..
end
