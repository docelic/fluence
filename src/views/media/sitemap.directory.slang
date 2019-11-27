ul
  - page.files.sort! {|a,b| a.name <=> b.name}.each do |file|
    li
      - file_name = file.name.chomp(".md").strip("/")
      - stack_join = stack.empty? ? nil : (stack.join("/") + "/")
      - if file.name =~ /\.md$/
        a href="/#{Fluence::OPTIONS.pages_prefix}/#{stack_join}#{file_name}"
          | #{Fluence::Page.new("#{stack_join}#{file_name}").title || file_name}
      - else
        | #{file_name}
    - if file.directory?
      == add_page(file, stack + [file_name])
