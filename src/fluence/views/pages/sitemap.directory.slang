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
        = pages[name][0]
        a href="/pages/#{name}"
          | (create)
    - if !page || page.directory?
      == add_page(Fluence::PAGES.children1( page ? page.name : name), stack << pages[name][0])
