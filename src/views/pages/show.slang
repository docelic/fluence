.col-xs-8
  == locals[:body_html]
.col-xs-4
  .col-xs-12
    a.btn.btn-md.btn-success href="/pages/#{locals[:path]}?edit"
      | Edit
  .col-xs-12
    ol.breadcrumb
      span.label.label-default Read
      - locals[:groups_read].as(Array(String)).each do |group|
        li
          | #{group}

    ol.breadcrumb
      span.label.label-default Write
      - locals[:groups_write].as(Array(String)).each do |group|
        li
          | #{group}
