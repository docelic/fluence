html
  head
    title
      = title
  body
    nav
      a href="/new" New page
      - unless current_path.nil?
        a href="/edit/#{current_path}" Edit
        a href="/delete/#{current_path}" Delet
    content
      == content
