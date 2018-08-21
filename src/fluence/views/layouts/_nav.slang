/ - active = context.request.path == "/" ? "active" : ""
/ a class="nav-item #{active}" href="/" Home
nav.navbar.navbar-light.bg-light.navbar-expand-lg
    a class="navbar-brand" href="#{Fluence::OPTIONS.homepage}"
      img.d-inline-block.align-top src="#{Fluence::OPTIONS.brand_logo}" alt="#{Fluence::OPTIONS.brand_info}"
      = Fluence::OPTIONS.brand
    button.navbar-toggler type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation"
      span.navbar-toggler-icon

    #navbarSupportedContent.collapse.navbar-collapse
      ul.navbar-nav.mr-auto
        li.nav-item class="active"
          a.nav-link href="#{Fluence::OPTIONS.homepage}" Home
            span.sr-only (current)
        li.nav-item
          a.nav-link href="/sitemap" Sitemap
        - if Fluence::ACL.permitted?(current_user, "#{Fluence::OPTIONS.admin_prefix}/users", Acl::Perm::Read)
          li.nav-item
            a.nav-link href="#{Fluence::OPTIONS.admin_prefix}/users" Users
        - if Fluence::ACL.permitted?(current_user, "#{Fluence::OPTIONS.admin_prefix}/acls", Acl::Perm::Read)
          li.nav-item
            a.nav-link href="#{Fluence::OPTIONS.admin_prefix}/acls" ACLs
        - if user_signed_in?
          li.navbar-text
            span | Logged in as
              = current_user.name
          li.nav-item
            a.nav-link href="#{Fluence::OPTIONS.users_prefix}/logout" (Logout)
        - else
          li.nav-item
            a.nav-link href="#{Fluence::OPTIONS.users_prefix}/login" | Login
            li.navbar-text or
            a.nav-link href="#{Fluence::OPTIONS.users_prefix}/register" Register
      form#search-page.my-2.d-inline.w-50 action="#{Fluence::OPTIONS.pages_prefix}/search" method="get"
        .input-group
          input.form-control.mr-sm-2 name="q" type="search" placeholder="Search" aria-label="Search" autocomplete="on"
          /      datalist#search-list
          /        - Fluence::PAGES.entries.values.each do |entry|
          /          option value=entry.url = entry.title
          button.btn.btn-outline-success.my-2.my-sm-0 type="submit" Search
