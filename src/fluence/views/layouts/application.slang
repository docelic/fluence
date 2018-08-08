doctype html
html lang="en"
  head
    title = title
    meta charset="utf-8"
    meta http-equiv="X-UA-Compatible" content="IE=edge"
    meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"

    link rel="stylesheet" href="/assets/stylesheet/bootstrap.min.css"
    / link rel="stylesheet" href="/assets/stylesheet/bootstrap-theme.min.css"
    script src="/assets/javascript/jquery-3.3.1.min.js"
    script src="/assets/javascript/popper.min.js"
    script src="/assets/javascript/bootstrap.min.js"
    link rel="stylesheet" href="/assets/stylesheet/highlight.min.css"
    script src="/assets/javascript/highlight.min.js"
    link rel="stylesheet" href="/assets/stylesheet/inscrybmde.min.css"
    script src="/assets/javascript/inscrybmde.min.js"
    link rel="stylesheet" href="/assets/stylesheet/base.css"
    script src="/assets/javascript/base.js"
    link rel="stylesheet" href="/assets/stylesheet/fine-uploader-new.min.css"
    script src="/assets/javascript/fine-uploader.min.js"

  body
    #navbar
      == render_template "layouts/_nav.slang"
    #main
      .container-fluid
        .row
        - flash.each do |key, value|
          div class="alert alert-#{ key }" role="alert"
            = flash[key]
        .row
          #content.container-fluid
            == content
