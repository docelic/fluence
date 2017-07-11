/ - active = context.request.path == "/" ? "active" : ""
/ a class="nav-item #{active}" href="/" Home
nav
  .pull-left
    a.btn.btn-md href="/" Home
    a.btn.btn-md href="/sitemap" Sitemap
    - if session["username"] || true
      = session["username"]
      - if current_user.has_group?("admin") || true
        a.btn.btn-md href="/admin/users" Users
        a.btn.btn-md href="/admin/acls" ACLs
        /- else
      a.btn.btn-md href="/users/register" Register
      a.btn.btn-md href="/users/login" Login
  .pull-right
    form#search-page action="/pages/search" method="get" role="form"
      .form-inline
        input.form-control name="q" type="text" placeholder="Search query"
        button.btn.btn-md
          span.glyphicon.glyphicon-search
          | Search
