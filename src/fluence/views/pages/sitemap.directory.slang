ul.list-unstyled
  - pages.sort{|a,b| a.name <=> b.name}.each do |page|
    li
      - file_name = page.name.strip("/")
      - stack_join = stack.empty? ? nil : (stack.join("/") + "/")
      - if page.exists?
        a href="#{page.url}"
          = page.title
      - else
        = file_name
    - if page.directory?
      == add_page(page.children1.values, stack + [file_name])
