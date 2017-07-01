macro new_render(name)
  macro render_{{name.id}}(page)
    render {{ "src/views/" + name.stringify + "s/\{\{page}}.html.slang" }}, "src/views/layout.html.slang"
  end
end

new_render(page)
new_render(user)

# macro render_page(page)
#   render {{ "src/views/pages/" + page + ".html.slang" }}, "src/views/layout.html.slang"
# end

require "./controllers/*"
