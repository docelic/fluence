require "markdown"

require "kemal"
require "crystal-libgit2"

require "./mdwikiface/*"

# lib C
#   fun chroot(path : Void*) : Int32
#   fun perror(err : Void*) : Void
# end

REPO = Libgitit2.open_repository(".")
# puts C.chroot(".")
# puts C.perror("Chroot: ")

private def get_file_path(env)
  "." + env.request.resource + ".md"
end

before_all do |env|
  file = get_file_path(env)
  begin
    rfile = File.real_path(file)
    chroot = Dir.current
    raise "Out of chroot" if chroot != rfile[0..(chroot.size - 1)]
    raise "Git directory" if "#{chroot}/.git" == rfile[0..(chroot.size + 4)]
  rescue
    raise "Unauthorized"
  end
end

get "/*" do |env|
  Markdown.to_html(File.read(get_file_path(env)))
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

Kemal.run
