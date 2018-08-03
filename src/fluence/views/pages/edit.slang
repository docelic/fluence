h1.page-header
  | Edit: #{page.title}

form#edit-page method="post"
  fieldset.col-xs-12
    div.input-group.col-xs-12
      textarea.form-control.textarea-resize name="body" type="body" = body
    div.input-group.col-xs-12
      input.form-control.btn.btn-block.btn-md.btn-success name="save" type="submit" value="save"
