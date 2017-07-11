doctype html
html
  head
    title Wikicr using Amber
    meta charset="utf-8"
    meta http-equiv="X-UA-Compatible" content="IE=edge"
    meta name="viewport" content="width=device-width, initial-scale=1"

    / link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"
    / link rel="stylesheet" href="/stylesheets/main.css"
    / jQuery
    script src="/assets/javascript/jquery-3.2.1.min.js"
    / Bootstrap
    link rel="stylesheet" href="/assets/stylesheet/bootstrap.min.css"
    link rel="stylesheet" href="/assets/stylesheet/bootstrap-theme.min.css"
    script src="/assets/javascript/bootstrap.min.js"
    / Custom
    link rel="stylesheet" href="/assets/stylesheet/base.css"
    script src="/assets/javascript/base.js"

  body
    div.masthead
      == render_template "layouts/_nav.slang"
    div.container
      div.row
      - flash.each do |key, value|
        div class="alert alert-#{ key }"
          p = flash[key]
      div.row
        div.col-sm-12.main
          h1.small.page-header
            | #{locals[:title]}
          #content
            == content
