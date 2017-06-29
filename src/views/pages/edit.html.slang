form#new-page method="post"
  fieldset
    legend
      | New wiki page: #{locals[:title]}
    div
      textarea name="body" type="body" = locals[:body]
    div
      input name="save" type="submit" value="save"
