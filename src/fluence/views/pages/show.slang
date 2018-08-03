#page-body.col-xs-12
  #page-body-meta.pull-right.col-xs-12.col-sm-4
    - if (index_entry = Fluence::PAGES[page]?) && (!index_entry.toc.empty?)
      #page-table-of-content
        span.page-body-meta-title Table of Contents
        == add_toc index_entry.toc
      div  
    - if Fluence::ACL.permitted? current_user, page.real_url, Acl::Perm::Write
      #page-edit.col-xs-12
        a.btn.btn-xs.btn-block.btn-warning href="/pages/#{page.url}?edit"
          | Edit
      div  
      #page-rename.col-xs-12
        form#rename-page method="post"
          fieldset
            .input-group.input-group-xs.col-xs-12
              input.input-sm.form-control name="new_path" type="text" placeholder="New url"
            .input-group.input-group-xs.col-xs-12
              button.btn.btn-xs.btn-block.btn-success name="rename" type="submit" value="rename" form="rename-page" Rename
      div  
      #page-permissions.col-xs-12
        span.page-body-meta-title Permissions
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
  #page-body-html.col-xs-10.col-sm-8 display="inline-block"
    form#edit-page method="post"
      fieldset.col-xs-12
        div.input-group.col-xs-12
          textarea.form-control name="body" = body
        div.input-group.col-xs-12
          input.form-control.btn.btn-block.btn-md.btn-success name="save" type="submit" value="Save"

script var editor = new InscrybMDE(Fluence.mde_options); editor.togglePreview();
