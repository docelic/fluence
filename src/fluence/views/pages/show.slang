script type="text/template" id="qq-template"
        div class="qq-uploader-selector qq-uploader" qq-drop-area-text="Drop files here"
            div class="qq-total-progress-bar-container-selector qq-total-progress-bar-container"
                div role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" class="qq-total-progress-bar-selector qq-progress-bar qq-total-progress-bar"
            div class="qq-upload-drop-area-selector qq-upload-drop-area" qq-hide-dropzone=""
                span class="qq-upload-drop-area-text-selector"
            div class="buttons"
                div class="qq-upload-button-selector qq-upload-button"
                    div Select files
                button type="button" id="trigger-upload" class="btn btn-primary"
                    i class="icon-upload icon-white"
                    | Upload
            span class="qq-drop-processing-selector qq-drop-processing"
                span Processing dropped files...
                span class="qq-drop-processing-spinner-selector qq-drop-processing-spinner"
            ul class="qq-upload-list-selector qq-upload-list" aria-live="polite" aria-relevant="additions removals"
                li
                    div class="qq-progress-bar-container-selector"
                        div role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" class="qq-progress-bar-selector qq-progress-bar"
                    span class="qq-upload-spinner-selector qq-upload-spinner"
                    img class="qq-thumbnail-selector" qq-max-size="100" qq-server-scale=""
                    span class="qq-upload-file-selector qq-upload-file"
                    span class="qq-edit-filename-icon-selector qq-edit-filename-icon" aria-label="Edit filename"
                    input class="qq-edit-filename-selector qq-edit-filename" tabindex="0" type="text"
                    span class="qq-upload-size-selector qq-upload-size"
                    button type="button" class="qq-btn qq-upload-cancel-selector qq-upload-cancel" Cancel
                    button type="button" class="qq-btn qq-upload-retry-selector qq-upload-retry" Retry
                    button type="button" class="qq-btn qq-upload-delete-selector qq-upload-delete" Delete
                    span role="status" class="qq-upload-status-text-selector qq-upload-status-text"

            dialog class="qq-alert-dialog-selector"
                div class="qq-dialog-message-selector"
                div class="qq-dialog-buttons"
                    button type="button" class="qq-cancel-button-selector" Close

            dialog class="qq-confirm-dialog-selector"
                div class="qq-dialog-message-selector"
                div class="qq-dialog-buttons"
                    button type="button" class="qq-cancel-button-selector" No
                    button type="button" class="qq-ok-button-selector" Yes

            dialog class="qq-prompt-dialog-selector"
                div class="qq-dialog-message-selector"
                input type="text"
                div class="qq-dialog-buttons"
                    button type="button" class="qq-cancel-button-selector" Cancel
                    button type="button" class="qq-ok-button-selector" Ok

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
      #page-media
        hr
        span.page-body-meta-title Page Media
        p
          div id="uploader"
          script var uploader = new qq.FineUploader({ element: document.getElementById("uploader"), request: { endpoint: '/media/upload' }, debug: true, deleteFile: { enabled: true, endpoint: '/media/upload' }, thumbnails: { placeholders: { waitingPath: '/assets/stylesheet/waiting-generic.png', notAvailablePath: '/assets/stylesheet/not_available-generic.png' } }, autoUpload: false}); qq(document.getElementById("trigger-upload")).attach("click", function() { uploader.uploadStoredFiles(); });
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
