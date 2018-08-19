ul.list-unstyled
  - names = pages.keys.sort!
  - names.each do |name|
    - page = pages[name][1]
    li
      - stack_join = stack.empty? ? nil : (stack.join("/") + "/")
      - if page
        a href="#{page.url}"
          = page.title
      - else
        = name
    - if !page || page.directory?
      == add_page(Fluence::PAGES.children1( page ? page.name : pages[name][0]), stack + [name])
