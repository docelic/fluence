.col-xs-8
  == body_html
.col-xs-4.sidebar
  - if Wikicr::ACL.permitted? current_user, page.real_url, Acl::Perm::Write
    .col-xs-12
      a.btn.btn-lg.btn-block.btn-warning href="/pages/#{page.url}?edit"
        | Edit this page
    .col-xs-12
      h2 Rename the page
      form#rename-page method="post"
        fieldset
          div.input-group.col-xs-12
            input.form-control name="new_path" type="text" placeholder="New url"
          div.input-group.col-xs-12
            button.btn.btn-sm.btn-block.btn-success name="rename" type="submit" value="rename" form="rename-page" rename
    .col-xs-12
      h2 Permissions
      p
        dl
          dt.text-center
            | Read
          dd.text-center
            - groups_read.each do |group|
              span.label.label-default
                | #{group}
              | 
          dt.text-center
            | Write
          dd.text-center
            - groups_write.each do |group|
              span.label.label-default
                | #{group}
              | 

  - if (index_entry = Wikicr::PAGES[page]?) && (!index_entry.toc.empty?)
    .col-xs-12
      h2 Table of Contents
      == add_toc index_entry.toc
