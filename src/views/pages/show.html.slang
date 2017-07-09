.col-xs-8
  == locals[:body_html]
.col-xs-4
  .col-xs-12
    a.btn.btn-md href="/pages/#{locals[:display_path]}?edit"
      | Edit
  / TODO: remove true
  - if current_user.has_group?("admin") || true
    .col-xs-12
      form#admin-pages-read method="post" action="/admin/pages/#{locals[:path]}"
        .input-group.col-xs-12
          label
            | Limited read to the groups:
          input.form-control name="groups" type="text"
        .input-group
          input.form-control.btn.btn-md.btn-warning name="change" type="submit" value="read"
    .col-xs-12
      form#admin-pages-write method="post" action="/admin/pages/#{locals[:path]}"
        .input-group.col-xs-12
          label
            | Limited write to the groups:
          input.form-control name="groups" type="text"
        .input-group
          input.form-control.btn.btn-md.btn-warning name="change" type="submit" value="write"

