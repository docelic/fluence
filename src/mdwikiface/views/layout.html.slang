html
  head
    title
      = locals[:title]
  body
    nav
      a href="/pages/new" New page
    div#content
      == content
