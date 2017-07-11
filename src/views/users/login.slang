form#login method="post"
  fieldset
    legend
      | Login
    div.input-group.col-xs-12
      label Username
      input.form-control name="username" type="text"
    div.input-group.col-xs-12
      input.form-control name="password" type="password"
    div.input-group
      input.form-control.btn.btn-md.btn-success name="login" type="submit" value="login"
