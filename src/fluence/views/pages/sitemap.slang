.container-fluid
  .row
    .col
      h1.page-header Sitemap
  .row
    .col
      span Pages
      #pages-hierarchy
        == add_page pages
    .col
      span Media
      #pages-hierarchy
        == add_page media
