.container-fluid
  .row-no-gutters
    .container.col-6
      h1 ACL Management
      h3 Create a new ACL
      form#acl-create method="post" action="#{Fluence::OPTIONS.admin_prefix}/acls/create"
        fieldset
          legend
            |ACL
          .form-group.row
            label.col-2.col-form-label for="input_group_acl" Groups
            .col-10
              input.form-control id="input_group_acl" name="groups" type="text"
          .form-group.row.pt-2
            label.col-2.col-form-label for="input_path_acl" Path
            .col-10
              input.form-control id="input_path_acl" name="path" type="text"
          .form-group.row.pt-2
            label.col-2.col-form-label for="input_permission_acl" Permission
            .col-10
              select.form-control id="input_permission_acl" name="perm" value="None" required="true" 
                option value="none" None
                option value="read" Read
                option value="write" Write
          .form-group.row.pt-2
            input.form-control.btn.btn-md.btn-success name="create" type="submit" value="Create"
    .row-no-gutters.pt-3
      .container
        h3 Manage Existing ACLs
        .row
          .col-3
            span style="font-weight:bold" Group
          .col-3
            label style="font-weight:bold" Page URL pattern
          .col-4
            label style="font-weight:bold" Current permission
          .col-2
            label style="font-weight:bold" Change permission to
        hr
        - acls.groups.each do |_, group|
          - group.permissions.each do |path, perm|
            .row.pt-1
              .col-2
                span=group.name
              .col-4
                span=path.to_s
              .col-4
                -case perm.to_s
                  -when "Write"
                    label.bg-success.px-2.py-2=perm.to_s
                  -when "Read"
                    label.bg-info.px-2.py-2=perm.to_s
                  -when "None"
                    label.bg-warning.px-2.py-2=perm.to_s
              .col-2
                .row
                  form.col-6#admin-acl method="post" action="#{Fluence::OPTIONS.admin_prefix}/acls/update"
                    input type="hidden" name="group" value=group.name
                    input type="hidden" name="path" value=path.to_s
                    button.btn.btn-xs.btn-success type="submit" name="change" value="write"
                      span Write
                  form.col-6#admin-acl method="post" action="#{Fluence::OPTIONS.admin_prefix}/acls/update"
                    input type="hidden" name="group" value=group.name
                    input type="hidden" name="path" value=path.to_s
                    button.btn.btn-xs.btn-info type="submit" name="change" value="read"
                      Span Read
                .row.pt-2
                  form.col-6#admin-acl method="post" action="#{Fluence::OPTIONS.admin_prefix}/acls/update"
                    input type="hidden" name="group" value=group.name
                    input type="hidden" name="path" value=path.to_s
                    button.btn.btn-xs.btn-warning type="submit" name="change" value="none"
                      Span None
                  form.col-6#admin-acl method="post" action="#{Fluence::OPTIONS.admin_prefix}/acls/delete"
                    input type="hidden" name="group" value=group.name
                    input type="hidden" name="path" value=path.to_s
                    button.btn.btn-xs.btn-danger type="submit" name="change" value="delete"
                      Span Delete
            hr  
