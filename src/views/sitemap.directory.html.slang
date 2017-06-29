ul
  - page.files.each do |file|
    li
      - file_name = file.name.chomp(".md")
      - stack_join = stack.join("/")
      a href="/pages/#{stack_join}/#{file_name}"
        | #{file_name}
    - if file.directory?
      == add_page(file, stack + [file.name])
