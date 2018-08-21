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
        a href="#{Fluence::OPTIONS.pages_prefix}/#{name}"
          = pages[name][0]
        span.small (empty)
    - if !page || page.directory?
      == add_page(Fluence::PAGES.children1( page ? page.name : name), stack << pages[name][0])
