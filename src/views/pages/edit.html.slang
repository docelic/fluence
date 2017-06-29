.col-xs-12
  form#edit-page method="post"
    fieldset
      legend
        | New wiki page: #{locals[:title]}
      div.input-group.col-xs-12
        textarea.form-control.textarea-resize name="body" type="body" = locals[:body]
      div.input-group
        input.form-control.btn.btn-md.btn-success name="save" type="submit" value="save"
