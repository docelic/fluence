h1.page-header Register

.constainer-fluid
  .row.no-gutters
    .col-3
      form#register method="post"
        fieldset
          legend
            | Register
          .form-group.row
            label.col-4.col-form-label for="input_username" Username
            .col-8
              input.form-control id="input_username" name="username" type="text"
          .form-group.row.pt-2
            label.col-4.col-form-label for="input_password" Password
            .col-8
              input.form-control id="input_password" name="password" type="password"
          .form-group.row.pt-2
            input.form-control.btn.btn-md.btn-success name="register" type="submit" value="Register"
