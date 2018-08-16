.container-fluid
  .row-no-gutters
    .container.col-6
      h1 User Managment 
      h3 Create a new User
      form#register-new-user method="post" action="/admin/users/create"
        fieldset
          legend
            | Admin
          .input-group
            .input-group-prepend
              span class="input-group-text" id="label-register-username" Username
            input.form-control name="username" type="text"
          .input-group.pt-2
            .input-group-prepend
              span class="input-group-text" id="label-register-username" Password
            input.form-control name="password" type="password"
          .input-group.pt-2
            .input-group-prepend
              span class="input-group-text" id="label-register-username" Groups
            input.form-control name="groups" type="text"
          .input-group.pt-2
            input.form-control.btn.btn-md.btn-success name="register" type="submit" value="Register"
  .row-no-gutters.pt-3
    .container
        h3 Manage existing users
        .row
          .col-4
            span style="font-weight:bold" Users
          .col-4
            label style="font-weight:bold" Groups
          .col-4
            label style="font-weight:bold" Action
        hr
        - users.each do |user|
          .row
            .col-4
              span=user.name
            .col-4
              span=user.groups.join(", ")
            .col-4
              form method="post" action="/admin/users/delete"
                input type="hidden" name="username" value=user.name
                input.form-control.btn.btn-md.btn-danger name="delete" type="submit" value="Delete"
          hr
