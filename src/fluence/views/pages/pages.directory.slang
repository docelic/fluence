ul.list-unstyled
  - names = entries.keys.sort!
  - names.each do |name|
    - page = entries[name][1]
    li
      - stack_join = stack.empty? ? nil : (stack.join("/") + "/")
      - if page
        a href="#{page.url}"
          = page.title
      - else
        a href="#{Fluence::OPTIONS.pages_prefix}/#{name}"
          = entries[name][0]
        span.small (empty)
    - if !page || page.directory?
      == add_page(Fluence::PAGES.children1( page ? page.name : name), stack << entries[name][0])
