.container.col-8
  .row
    .col
      h1 ACL Management
      .row
        .col
          h2 Create a new ACL
            form#acl-create method="post" action="/admin/acls/create"
              fieldset
                div.input-group.col-xs-12
                  label Group
                  input.form-control name="group" type="text" required="true"
                div.input-group.col-xs-12
                  label Path
                  input.form-control name="path" type="text" required="true"
                div.input-group.col-xs-12
                  label Permission
                  select.form-control name="perm" value="None" required="true"
                    option value="none" None
                    option value="read" Read
                    option value="write" Write
                div.input-group
                  input.form-control.btn.btn-md.btn-success name="create" type="submit" value="create"
    .w-100
    .col.mt-3
      h2 Manage Existing ACLs
      table.table.table-condensed
        thead
          tr
            th Concerned
            th Path
            th Permission
            th Action
        tbody
          - acls.groups.each do |_, group|
            - group.permissions.each do |path, perm|
              tr
                td.col-xs-2 = group.name
                td.col-xs-6 = path.to_s
                - case perm.to_s
                  - when "Write"
                    td.col-xs-1.bg-success = perm.to_s
                  - when "Read"
                    td.col-xs-1.bg-info = perm.to_s
                  - when "None"
                    td.col-xs-1.bg-warning = perm.to_s
                td.col-xs-3
                  form.col-xs-3#admin-acl method="post" action="/admin/acls/update"
                    input type="hidden" name="group" value=group.name
                    input type="hidden" name="path" value=path.to_s
                    button.btn.btn-xs.btn-success type="submit" name="change" value="write"
                      span Write
                  form.col-xs-3#admin-acl method="post" action="/admin/acls/update"
                    input type="hidden" name="group" value=group.name
                    input type="hidden" name="path" value=path.to_s
                    button.btn.btn-xs.btn-info type="submit" name="change" value="read"
                      Span Read
                  form.col-xs-3#admin-acl method="post" action="/admin/acls/update"
                    input type="hidden" name="group" value=group.name
                    input type="hidden" name="path" value=path.to_s
                    button.btn.btn-xs.btn-warning type="submit" name="change" value="none"
                      Span None
                  form.col-xs-3#admin-acl method="post" action="/admin/acls/delete"
                    input type="hidden" name="group" value=group.name
                    input type="hidden" name="path" value=path.to_s
                    button.btn.btn-xs.btn-danger type="submit" name="change" value="delete"
                      Span Delete
