h1.page-header Register

form#register method="post"
  fieldset
    legend
      | Register
    div.input-group.col-xs-12
      label Username
      input.form-control name="username" type="text"
    div.input-group.col-xs-12
      label Password
      input.form-control name="password" type="password"
    div.input-group
      input.form-control.btn.btn-md.btn-success name="register" type="submit" value="register"
