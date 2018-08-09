/ - active = context.request.path == "/" ? "active" : ""
/ a class="nav-item #{active}" href="/" Home
nav.navbar.navbar-expand-lg.bg-light
  .container-fluid
    a.navbar-brand href="#" Fluence
    button.navbar-toggler type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation"
      span.navbar-toggler-icon

    #navbarSupportedContent.collapse.navbar-collapse
      ul.navbar-nav.mr-auto
        li.nav-item class="active"
          a.nav-link href="/pages/home" Home
            span.sr-only (current)
        li.nav-item
          a.nav-link href="/sitemap" Sitemap
        - if Fluence::ACL.permitted?(current_user, "/admin/users", Acl::Perm::Read)
          li.nav-item
            a.nav-link href="/admin/users" Users
        - if Fluence::ACL.permitted?(current_user, "/admin/acls", Acl::Perm::Read)
          li.nav-item
            a.nav-link href="/admin/acls" ACLs
        - if user_signed_in?
          li.navbar-text
            span | Logged in as
              = current_user.name
          li.nav-item
            a.nav-link href="/users/logout" (Logout)
        - else
          li.nav-item
            a.nav-link href="/users/login" | Login
            li.navbar-text or
            a.nav-link href="/users/register" Register
      form#search-page.form-inline.my-2.my-md-0 action="/pages/search" method="get"
        input.form-control.mr-sm-2 name="q" type="search" placeholder="Search" aria-label="Search" autocomplete="on"
        /      datalist#search-list
        /        - Fluence::PAGES.entries.values.each do |entry|
        /          option value=entry.url = entry.title
        button.btn.btn-outline-success.my-2.my-sm-0 type="submit" Search
