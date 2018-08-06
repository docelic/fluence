/ - active = context.request.path == "/" ? "active" : ""
/ a class="nav-item #{active}" href="/" Home
nav class="navbar navbar-light bg-light"
  .col-sm-6
    .pull-left
      a.btn.btn-md href="/" Home
      a.btn.btn-md href="/sitemap" Sitemap
      - if !user_signed_in?
        /a.btn.btn-md href="/users/register" Register
        /a.btn.btn-md href="/users/login" Login
      - if Fluence::ACL.permitted?(current_user, "/admin/users", Acl::Perm::Read)
        a.btn.btn-md href="/admin/users" Users
      - if Fluence::ACL.permitted?(current_user, "/admin/acls", Acl::Perm::Read)
        a.btn.btn-md href="/admin/acls" ACLs
  .col-sm-3
    .center-block
      form#search-page action="/pages/search" method="get" role="form"
        .input-group.input-group-md
          input.input-md.form-control name="q" placeholder="Search query" autocomplete="on" list="search-list"
          datalist#search-list
            - Fluence::INDEX.entries.values.each do |entry|
              option value=entry.url = entry.title
          span.input-group-btn
            button.btn.btn-md
              span.glyphicon.glyphicon-search
              | Search
  .col-sm-2
    .pull-right
      - if user_signed_in?
         span Logged in as
           = current_user.name
         a.btn.btn-md href="/users/logout" Logout
      - else
         a.btn.btn-md href="/users/login" Login
         | or
         a.btn.btn-md href="/users/register" Register
