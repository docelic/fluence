html
  head
    title
      = locals[:title]
    / jQuery
    script src="/assets/javascript/jquery-3.2.1.min.js"
    / Bootstrap
    link rel="stylesheet" href="/assets/stylesheet/bootstrap.min.css"
    link rel="stylesheet" href="/assets/stylesheet/bootstrap-theme.min.css"
    script src="/assets/javascript/bootstrap.min.js"
    / Custom
    link rel="stylesheet" href="/assets/stylesheet/base.css"
    script src="/assets/javascript/base.js"

    / link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"
    / link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous"
    / script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"
  body
    nav
      .pull-left
        a.btn.btn-md href="/" Home
        a.btn.btn-md href="/sitemap" Sitemap
        - if env.session.string?("username")
          = env.session.string("username")
          - if current_user.has_group? "admin"
            a.btn.btn-md href="/users/admin" Admin
        - else
          a.btn.btn-md href="/users/register" Register
          a.btn.btn-md href="/users/login" Login
      .pull-right
        form#search-page action="/pages/search" method="get" role="form"
          .form-inline
            input.form-control name="q" type="text" placeholder="Search query"
            button.btn.btn-md
              span.glyphicon.glyphicon-search
              | Search
    div.container
      .col-xs-12
        h1.small.page-header
          | #{locals[:title]}
        #content
          == content
