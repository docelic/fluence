/ - active = context.request.path == "/" ? "active" : ""
/ a class="nav-item #{active}" href="/" Home
nav class="navbar navbar-default"
  .col-xs-6
    .pull-left
      - if user_signed_in?
        a.btn.btn-lg href="/" = current_user.name
      a.btn.btn-lg href="/" Home
      a.btn.btn-lg href="/sitemap" Sitemap
      - if !user_signed_in?
        a.btn.btn-lg href="/users/register" Register
        a.btn.btn-lg href="/users/login" Login
      - if Wikicr::ACL.permitted?(current_user, "/admin/users", Acl::Perm::Read)
        a.btn.btn-lg href="/admin/users" Users
      - if Wikicr::ACL.permitted?(current_user, "/admin/acls", Acl::Perm::Read)
        a.btn.btn-lg href="/admin/acls" ACLs
  .col-xs-6
    .pull-right
      form#search-page action="/pages/search" method="get" role="form"
        .input-group.input-group-lg
          input.form-control name="q" placeholder="Search query" autocomplete="on" list="search-list"
          datalist#search-list
            - Wikicr::PAGES.entries.values.each do |entry|
              option value=entry.url = entry.title
          span.input-group-btn
            button.btn.btn-lg
              span.glyphicon.glyphicon-search
              | Search
