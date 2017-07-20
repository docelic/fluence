doctype html
html
  head
    title Wikicr
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
    #navbar
      == render_template "layouts/_nav.slang"
    #main
      .container
        .row
        - flash.each do |key, value|
          div class="alert alert-#{ key }"
            p = flash[key]
        .row
          #content.col-sm-12
            == content
