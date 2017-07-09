require "./wikicr"

macro new_render(name, dir)
  macro render_{{name.id}}(page)
    render {{"src/views/" + dir + "/\{\{page}}.html.slang"}}, "src/views/layout.html.slang"
  end
end

macro new_render(name)
  new_render({{name}}, {{name}})
end

new_render("pages")
new_render("users")
new_render("admin", "admin")

require "./controllers/*"
