h1.page-header Users Management

h2 Create a new User
form#register-new-user method="post" action="/admin/users/create"
  fieldset
    legend
      | Admin
    div.input-group.col-xs-12
      label Username
      input.form-control name="username" type="text"
    div.input-group.col-xs-12
      label Password
      input.form-control name="password" type="password"
    div.input-group.col-xs-12
      label Groups
      input.form-control name="groups" type="text"
    div.input-group
      input.form-control.btn.btn-md.btn-success name="register" type="submit" value="register"


h2 Manage existing users
table.table.table-condensed
  thead
    tr
    th Username
      th Groups
      th Action
  tbody
    - locals[:users].each do |user|
      tr
        td= user.name
        td= user.groups.join(", ")
        td
          form method="post" action="/admin/users/delete"
            input type="hidden" name="username" value=user.name
            input.form-control.btn.btn-md.btn-danger name="delete" type="submit" value="delete"
