h1.page-header Login

.constainer-fluid
  .row.no-gutters
    .col-3
      form#register method="post"
        fieldset
          legend
            | Login
          .input-group
            .input-group-prepend
              span class="input-group-text" id="label-register-username" Username
            input.form-control name="username" type="text"
          .input-group.pt-2
            .input-group-prepend
              span class="input-group-text" id="label-register-username" Password
            input.form-control name="password" type="password"
          .input-group.pt-2
            input.form-control.btn.btn-md.btn-success name="login" type="submit" value="Login"