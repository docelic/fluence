#page-body

  #page-body-menu.col-xs-2
    span.page-body-meta-title Wiki Pages
    p
      == add_page pages

  #page-body-html.col-xs-8
    form#edit-page method="post"
      fieldset
        div.input-group.col-xs-12
          textarea.form-control name="body" = body

  #page-body-meta.col-xs-2
      #page-toc
        span.page-body-meta-title Table of Contents
        p
          - if (index_entry = Fluence::PAGES[page]?) && (!index_entry.toc.empty?)
              == add_toc index_entry.toc
      #page-intlinks
        hr
        span.page-body-meta-title Internal Links
        p
          ol
            - page.internal_links.each do |linkspec|
              - pg = Fluence::Page.new linkspec[1]
              li
                a href="#{pg.real_url}" = pg.title || pg.url
    - if Fluence::ACL.permitted? current_user, page.real_url, Acl::Perm::Write
      #page-content
        hr
        span.page-body-meta-title Page Content
        p
          a.btn.btn-xs.btn-block.btn-success href="#" onclick="editor.togglePreview()" Toggle edit
          button.btn.btn-xs.btn-block.btn-success name="save" type="submit" value="save" form="edit-page" Save
      #page-management
        hr
        span.page-body-meta-title Page Management
        p
          form#manage-page method="post"
            fieldset
              .input-group.input-group-xs.col-xs-12
                input.input-sm.form-control name="new_path" type="text" value="#{page.url}"
              .input-group.input-group-xs.col-xs-12
                input.input-sm.form-control name="new_path_overwrite" type="checkbox" value="0" Overwrite
                button.btn.btn-xs.btn-block.btn-warning name="rename" type="submit" value="rename" form="manage-page" Rename
              .input-group.input-group-xs.col-xs-12
                button.btn.btn-xs.btn-block.btn-danger name="delete" type="submit" value="delete" form="manage-page" onclick="return confirm('Really delete page `#{page.url}`?')" Delete
      #page-permissions
        hr
        span.page-body-meta-title Page Permissions
        p
          dl
            dt.text-center
              | Read
            dd.text-center
              - groups_read.each do |group|
                span.label.label-default
                  e #{group}
                | 
            dt.text-center
              | Write
            dd.text-center
              - groups_write.each do |group|
                span.label.label-default
                  | #{group}
                | 

script
  = "var editor = new InscrybMDE(Fluence.mde_options(#{Fluence::ACL.permitted? current_user, page.real_url, Acl::Perm::Write}));"
  - if File.exists? page.path
    = "editor.togglePreview();"
