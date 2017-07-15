/ - active = context.request.path == "/" ? "active" : ""
/ a class="nav-item #{active}" href="/" Home
nav
  .pull-left
    a.btn.btn-md href="/" Home
    a.btn.btn-md href="/sitemap" Sitemap
    - if user_name?
      = user_name?
    - else
      a.btn.btn-md href="/users/register" Register
      a.btn.btn-md href="/users/login" Login
    - if Wikicr::ACL.permitted?(current_user, "/admin/", Acl::Perm::Write)
      a.btn.btn-md href="/admin/users" Users
      a.btn.btn-md href="/admin/acls" ACLs
  .pull-right
    form#search-page action="/pages/search" method="get" role="form"
      .form-inline
        input.form-control name="q" placeholder="Search query" autocomplete="on" list="search-list"
        datalist#search-list
          - Wikicr::PAGES.entries.values.each do |entry|
            option value=entry.url = entry.title
        button.btn.btn-md
          span.glyphicon.glyphicon-search
          | Search
