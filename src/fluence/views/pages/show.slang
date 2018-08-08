script type="text/template" id="qq-template"
        div class="qq-uploader-selector qq-uploader" qq-drop-area-text="Drop files here"
            div class="qq-total-progress-bar-container-selector qq-total-progress-bar-container"
                div role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" class="qq-total-progress-bar-selector qq-progress-bar qq-total-progress-bar"
            div class="qq-upload-drop-area-selector qq-upload-drop-area" qq-hide-dropzone=""
                span class="qq-upload-drop-area-text-selector"
            div class="buttons"
                div class="qq-upload-button-selector btn btn-primary"
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
.container-fluid.mt-3
  .row
    .col
      span Wiki Pages
      .ml-2
         == add_page pages

    .col-sm-8
      .row
        .col-12
          form#edit-page method="post"
            fieldset
              textarea.form-control name="body" = body
        .col-12
          span Page Media
            div id="uploader"
            script var uploader = new qq.FineUploader({ element: document.getElementById("uploader"), request: { endpoint: '/media/upload' }, debug: true, deleteFile: { enabled: true, endpoint: '/media/upload' }, thumbnails: { placeholders: { waitingPath: '/assets/stylesheet/waiting-generic.png', notAvailablePath: '/assets/stylesheet/not_available-generic.png' } }, autoUpload: false}); qq(document.getElementById("trigger-upload")).attach("click", function() { uploader.uploadStoredFiles(); });

    .col
      .row.no-gutters
        #page-toc.col-12
          span Table of Contents
          - if (index_entry = Fluence::INDEX[page]?) && (!index_entry.toc.empty?)
            == add_toc index_entry.toc
          hr
        #page-intlinks.col-12
          span Internal Links
          ol
            - page.internal_links.each do |linkspec|
              - pg = Fluence::Page.new linkspec[1]
              li
                a href="#{pg.real_url}" = pg.title || pg.url
          hr
        - if Fluence::ACL.permitted? current_user, page.real_url, Acl::Perm::Write
          #page-content.col-12
            span Page Content
            .row
              .col
                a.btn.btn-sm.btn-block.btn-success href="#" onclick="editor.togglePreview()" Toggle edit
              .col
                button.btn.btn-sm.btn-block.btn-success name="save" type="submit" value="save" form="edit-page" Save
            hr
        #page-management.col-12
          span Page Management
            form#manage-page method="post"
              .input-group
                .input-group-prepend
                  span class="input-group-text" id="label-page-name" Page name
                input type="text" class="form-control" id="input-page-name" name="input-page-name" aria-describedby="label-page-name" value="#{page.url}"
              .row.mt-2
                .col
                  .form-group.form-check
                   input type="checkbox" class="form-check-input" id="input-page-overwrite" name="input-page-overwrite"
                   label class="form-check-label" for="input-page-overwrite" Overwrite
                .col
                  button.btn.btn-sm.btn-block.btn-warning name="rename" type="submit" value="rename" form="manage-page" Rename
              .row
                .col
                .col
                  button.btn.btn-sm.btn-block.btn-danger name="delete" type="submit" value="delete" form="manage-page" onclick="return confirm('Really delete page `#{page.url}`?')" Delete
          hr
 
        #page-permissions.col-12
          span Page Permissions
          .row
            .col-auto
              | Read:
            .col
              = groups_read.join ", "
            .w-100
            .col-auto
              | Write:
            .col
              = groups_write.join ", "
script
  = "var editor = new InscrybMDE(Fluence.mde_options(#{Fluence::ACL.permitted? current_user, page.real_url, Acl::Perm::Write}));"
  - if File.exists? page.path
    = "editor.togglePreview();"
