.col-xs-8
  == body_html
.col-xs-4
  .col-xs-12
    a.btn.btn-md.btn-success href="/pages/#{page.url}?edit"
      | Edit
  .col-xs-12
    ol.breadcrumb
      span.label.label-default Read
      - groups_read.each do |group|
        li
          | #{group}

    ol.breadcrumb
      span.label.label-default Write
      - groups_write.each do |group|
        li
          | #{group}
