ul.list-indent
  - page.files.sort! {|a,b| a.name <=> b.name}.each do |file|
    li
      - file_name = file.name.chomp(".md").strip("/")
      - stack_join = stack.empty? ? nil : (stack.join("/") + "/")
      - if file.name =~ /\.md$/
        a href="/pages/#{stack_join}#{file_name}"
          | #{Fluence::Page.new("#{stack_join}#{file_name}", false, true).title || file_name}
      - else
        | #{file_name}
    - if file.directory?
      == add_page(file, stack + [file_name])
