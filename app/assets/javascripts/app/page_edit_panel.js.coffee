#= require shared/underscore
#= require shared/backbone
#= require app/panel
#= require app/markdown_toolbar
#= require models/page
#= require shared/defer
#= require shared/labeled_button
#= require shared/modal_dialog
#= require shared/diff
#= require shared/utils
#= require shared/localstorage
#= require shared/marked
#= require bootstrap-growl-ifightcrime/jquery.bootstrap-growl
#= require jquery-ui/custom

class LeaveConfirmationDialog extends ModalDialog
  el: $('#page-edit-leave')

class ConflictDialog extends ModalDialog
  el: $('#page-edit-conflict')

class LoadDraftDialog extends ModalDialog
  el: $('#page-edit-load-draft')

class LoadErrorDialog extends ModalDialog
  el: $('#page-edit-load-error')

class LoadNotFoundDialog extends ModalDialog
  el: $('#page-edit-load-notfound')

class SaveErrorDialog extends ModalDialog
  el: $('#page-edit-save-error')
  constructor: (message) ->
    $('#page-edit-save-error-label-message').text(message)

class DeletePageDialog extends ModalDialog
  el: $('#edit-page-delete')

class DeletePageErrorDialog extends ModalDialog
  el: $('#edit-page-delete-error')


if is_ios() && is_app()
  sessionStorage = window.localStorage
else
  sessionStorage = window.sessionStorage

class PageEditPanel extends AbsolutePanel
  @el:
    new_tab: "#navigator-new"
    edit_tab: "#navigator-edit"
    navigator: "#navigator"

    container: "#edit-page-container"
    title: if device_type() == "phone" then "#edit-page-title-phone" else "#edit-page-title"
    body: if device_type() == "phone" then "#edit-page-body-phone" else "#edit-page-body"
    bottom_bar: if device_type() == "phone" then "#edit-page-bottom-bar-phone" else "#edit-page-bottom-bar"
    loading: "#edit-page-loading"

    pane_handle: "#edit-page-pane-handle"
    main_pane: "#edit-page-main-pane"
    sidebar_pane: "#edit-page-sidebar-pane"
    tab_pane: "#edit-page-sidebar-tab-content"
    preview: "#edit-page-preview"
    preview_body: "#edit-page-preview-body"
    preview_wordcount: "#edit-page-preview-wordcount"
    preview_tab: "#edit-page-tab-preview"
    edit_tab: "#edit-page-tab-edit"
    save_button: if device_type() == "phone" then "#edit-page-save-phone" else "#edit-page-save"
    delete_button: "#edit-page-delete-btn"
    autosave_check: "#edit-page-autosave-check"
    fontname: "#edit-fontname"

    hide_after_save: "#help-welcome"

  constructor: ->
    super(PageEditPanel)

    @change_font()

    $('#edit_font_proportional_xlarge').click =>
      @change_font 'proportinal', 'xlarge'
    
    $('#edit_font_proportional_large').click =>
      @change_font 'proportinal', 'large'
    
    $('#edit_font_proportional_medium').click =>
      @change_font 'proportinal', 'medium'
    
    $('#edit_font_proportional_small').click =>
      @change_font 'proportinal', 'small'
    
    $('#edit_font_fixed_xlarge').click =>
      @change_font 'fixed', 'xlarge'
    
    $('#edit_font_fixed_large').click =>
      @change_font 'fixed', 'large'
    
    $('#edit_font_fixed_medium').click =>
      @change_font 'fixed', 'medium'
    
    $('#edit_font_fixed_small').click =>
      @change_font 'fixed', 'small'

    @save_button = new LabeledButton(@save_button_el)
    @save_button.el.click => @save()

    @page = undefined
    @lock_version = -1

    self = @
    $('#edit-page-sidebar-tab a').click (e) ->
      e.preventDefault()
      $(@).tab('show')
      self.resize()

    @delete_button_el.click =>
      (new DeletePageDialog).show().done =>
        if @page && ((@page.key || '') != '')
          destroy_defer = @page.destroy()
          destroy_defer.done =>
            @page = undefined
            Backbone.history.navigate('notes', {trigger: true})
          destroy_defer.fail (error, mesg) =>
            dialog = new DeletePageErrorDialog();
            dialog.show()
        else
            @page = undefined
            Backbone.history.navigate('notes', {trigger: true})

    @autosave_check_el.on 'change', =>
      session.autosave(@autosave_check_el.prop("checked"))

    session.on 'update_autosave', =>
      @autosave_check_el.prop("checked", session.autosave())

    setInterval =>
      @preview()
    , 1000

    setInterval =>
      @autosave()
    , 60 * 1000

    if device_type() == 'desktop'
      $(".btn", @bottom_bar_el).tooltip('hide')
    else
      $(".btn", @bottom_bar_el).tooltip('destroy')

    if device_type() == 'desktop'
      win = $(window)
      @pane_handle_el.draggable
        axis: "x"
        drag: (ev, ui) =>
          w = win.width() - ui.position.left - 90 - 24;
          @main_pane_el.css('right', "#{w}px")
          @sidebar_pane_el.width(w)

    $(window).bind 'beforeunload', =>
      if @is_active && @page && @is_changed()
        "You have some changes that have not been saved."
      else
        undefined

  activate: (page) ->
    Deferred (defer) =>
      done = =>
        @page.on 'update', (old_data) =>
          form_is_changed = old_data.page.title != @title_el.val() || old_data.page.body != @body_el.val()
          if form_is_changed
            @merge(@page.body, old_data.page.body, @body_el.val(), @page.lock_version)
          else
            $.bootstrapGrowl("Loaded latest version", {type: 'success'});
            @page_to_form()
        if device_type() == 'phone'
          $('a', @edit_tab_el).tab('show') 
        else
          $('a', @preview_tab_el).tab('show') 
        if @page.lock_version == @lock_version
          # todo: merge3
        else
          @page_to_form() 
        @loading_el.hide()
        @body_el.focus()
        defer.resolve()

      if page
        @edit_tab_el.tab('show')
      else
        @new_tab_el.tab('show')

      @form_clear()
      @resize() unless device_type() == 'phone'

      @loading_el.show()
      if (typeof page) == 'string'
        @page = new Page()
        @page.key = page
        @load_draft()
        load_defer = @page.load(page)
        load_defer.always => @loading_el.hide()
        load_defer.done => done()
        load_defer.fail (error_type, error_message, error_object) =>
          if error_type == 'notfound'
            @page = new Page()
            @page_to_form()
            (new LoadNotFoundDialog()).show().always =>
              delay 100, => @body_el.focus()
            defer.resolve()
          else
            (new LoadErrorDialog()).show()
            defer.reject(error_type, error_message, error_object)
      else
        @page = page || new Page()
        @load_draft()
        done()

  deactivate: ->
    Deferred (defer) =>
      @form_to_page()
      if @page && @page.is_changed()
        dialog = new LeaveConfirmationDialog()
        dialog_defer = dialog.show()
        dialog_defer.done =>
          @container_el.hide()
          @clear_draft()
          @navigator_el.show()
          defer.resolve()
        dialog_defer.fail =>
          delay 100, => @body_el.focus()
          defer.reject()
      else
        @container_el.hide()
        @clear_draft()
        @navigator_el.show()
        defer.resolve()

  focus: ->
    @page.check_update() if @page && !@page.request

  form_clear: ->
    if device_type() == 'phone'
      @edit_tab_el.tab('show')
    else
      @preview_tab_el.tab('show')
    @title_el.val('')
    @body_el.val('')
    @lock_version = -1
    @save_button.label('save')
    @preview_body_el.html('')
    @preview_wordcount_el.html('')
    @previewed_body = ''

  page_to_form: ->
    if @page && @page.lock_version != @lock_version
      @title_el.val(@page.title)
      @body_el.val(@page.body)
      @lock_version = @page.lock_version
      @preview()

  form_to_page: ->
    if @page
      @page.title = @title_el.val()
      @page.body = @body_el.val()
      @page.lock_version = @lock_version
      @save_draft()

  is_changed: ->
    @page && ( @page.saved_data.body != @body_el.val() || @page.saved_data.title != @title_el.val() )

  save: ->
    if @is_active && !ModalDialog.is_active()
      Deferred (defer) =>
        if @save_button.label() == 'saving'
          defer.reject()
        else
          @save_button.label('saving')
          @form_to_page()
          save_defer = @page.save()

          save_defer.always =>
            @save_button.label('save')

          save_defer.done =>
            if @page && @page.lock_version == @lock_version+1
              @page.title = @title_el.val()
              @page.body = @body_el.val()
              @lock_version = @page.lock_version
            else
              @page_to_form()
            Backbone.history.navigate("#{@page.key}/edit", {trigger: false})
            $.bootstrapGrowl("Saved", {type: 'success'});
            @hide_after_save_el.empty()
            defer.resolve()
            analytics.event(ev: 'Edit', ea: 'Save')

          save_defer.fail (error, option1) =>
            if error == 'conflict'
              @merge(@body_el.val(), @page.saved_data.body, option1.body, option1.lock_version)
            else
              dialog = new SaveErrorDialog(option1);
              dialog.show().always =>
                delay 100, => @body_el.focus()
            defer.reject()

  merge: (a, o, b, lock_version) ->
    current_body = a.replace("\r", '').split(/\n/)
    saved_body = o.replace("\r", '').split(/\n/)
    server_body = b.replace("\r", '').split(/\n/)
    merged = Diff.diff3_merge(current_body, saved_body, server_body)
    
    merged_text = '';
    merged.forEach (block) ->
      if block.ok
        block.ok.forEach (line) ->
          merged_text += "#{line}\n"
      else if block.conflict
        block.conflict.a.forEach (line) ->
          merged_text += "#{line}\n"
        block.conflict.o.forEach (line) ->
          # merged_text += "#{line}\n" 
        block.conflict.b.forEach (line) ->
          merged_text += "#{line}\n"

    body_el = @body_el.get(0)
    cur = body_el.selectionStart

    @body_el.val(merged_text)
    @lock_version = @page.lock_version = lock_version
    (new ConflictDialog()).show().always =>
      delay 100, =>
        @body_el.focus()
        body_el.selectionStart = cur
        body_el.selectionEnd = cur
    analytics.event(ev: 'Edit', ea: 'MergeDialog')

  preview: () ->
    if @is_active
      @save_draft()
      body = @body_el.val()
      if @previewed_body != body
        @previewed_body = body
        tokens = marked.lexer(@previewed_body)
        @preview_body_el.html("<div class=\"content\">#{marked.parser(tokens)}</div>")

        # word counter
        chars_m = body.match(/[^\u0000-\u0020]/g)
        chars = if chars_m then chars_m.length else 0
        if body.trim() == ''
          words = 0
        else
          words = body.trim().split(/\s+/g).length
        lines_m = body.trim().match(/[\r\n]+/g) 
        lines = if lines_m then lines_m.length else 0
        @preview_wordcount_el.html("C: <strong>#{chars}</strong>, W: <strong>#{words}</strong>, L: <strong>#{lines}</strong>")

  resize: () -> 
    @container_el.show()
    @full_height(@body_el, @bottom_bar_el.height() + (if device_type() == 'phone' then 0 else 4) + 16 + 6)
    @full_height(@sidebar_pane_el, (if device_type() == 'phone' then 2 else 8))
    @full_height(@tab_pane_el, (if device_type() == 'phone' then 2 else 9))
    @full_height(@loading_el, 2);
    @pane_handle_el.css('left', $(window).width()-@sidebar_pane_el.width() - 90 - 24)

  hotkeys: (ev, keychar) ->
    keycode2char =
      0x09: "\t"
      0x20: " "
      0xbd: "-"

    if ev.shiftKey && (ev.ctrlKey || ev.metaKey || ev.altKey)
      switch keychar
        when 'I'
          ev.preventDefault()
          Backbone.history.navigate('notes', {trigger: true})

        when 'T'
          ev.preventDefault()
          markdownToolbar.insertToday() if markdownToolbar

    else if ev.ctrlKey || ev.metaKey || ev.altKey
      switch keychar
        when 'S'
          ev.preventDefault()
          @save()

    else if ev.shiftKey && !ev.ctrlKey && !ev.metaKey && !ev.altKey
      switch ev.keyCode
        when 0x09, 0x20, 0xbd # tab-key, space, -
          if $(':focus').attr('id') == 'edit-page-body'
            if @body_el.isTextSelected()
              ev.preventDefault()
              @body_el.removeToSelection(keycode2char[ev.keyCode])

    else if !ev.shiftKey && !ev.ctrlKey && !ev.metaKey && !ev.altKey
      switch ev.keyCode
        when 0x09, 0x20, 0xbd # tab-key, space, -
          if $(':focus').attr('id') == 'edit-page-body'
            if @body_el.isTextSelected()
              ev.preventDefault()
              @body_el.insertToSelection(keycode2char[ev.keyCode])
            else
              if markdownToolbar && ev.keyCode == 0x09
                ev.preventDefault()
                markdownToolbar.insertTab()

  load_draft: -> 
    draft_key = sessionStorage['page-edit-key']
    if typeof draft_key != 'undefined'
      draft_body = sessionStorage['page-edit-body']
      draft_title = sessionStorage['page-edit-title']
      draft_lock_version = sessionStorage['page-edit-lock-version']

      if @page && (@page.key || '') == draft_key
        use_draft = =>
          @body_el.val(@page.body = draft_body)
          @title_el.val(@page.title = draft_title)
          @lock_version = if draft_lock_version=='' then undefined else parseInt(draft_lock_version)

        if is_app()
          delay 500, => @body_el.focus()
          use_draft()
        else
          defer = (new LoadDraftDialog).show()
          defer.always =>
            delay 500, => @body_el.focus()
          defer.done =>
            use_draft()
          defer.fail =>
            @clear_draft()

  save_draft: ->
    if @is_active
      if @page && (@body_el.val() != @page.saved_data.body || @title_el.val() != @page.saved_data.title)
        sessionStorage['page-edit-key'] = @page.key || ''
        sessionStorage['page-edit-body'] = @body_el.val()
        sessionStorage['page-edit-title'] = @title_el.val()
        sessionStorage['page-edit-lock-version'] = @page.lock_version || ''
      else
        @clear_draft()

  clear_draft: ->
    sessionStorage.removeItem('page-edit-key')
    sessionStorage.removeItem('page-edit-body')
    sessionStorage.removeItem('page-edit-title')
    sessionStorage.removeItem('page-edit-lock-version')

  autosave: ->
    if @page && session.autosave() && !ModalDialog.is_active()
      data = @page.saved_data || { body: @page.body, title: @page.title }
      if data.body != @body_el.val() || data.title != @title_el.val()
        @save()

  change_font: (fontname, fontsize) ->
    fontname = localStorage.editor_fontname || 'proportinal' unless fontname
    fontsize = localStorage.editor_fontsize || 'small' unless fontsize

    @fontname_el.removeClass("edit_fontname_#{localStorage.editor_fontname}")
    @body_el.removeClass("edit_fontname_#{localStorage.editor_fontname}")
    @body_el.removeClass("edit_fontsize_#{localStorage.editor_fontsize}")
    localStorage.editor_fontname = fontname
    localStorage.editor_fontsize = fontsize
    @fontname_el.addClass("edit_fontname_#{localStorage.editor_fontname}")
    @body_el.addClass("edit_fontname_#{localStorage.editor_fontname}")
    @body_el.addClass("edit_fontsize_#{localStorage.editor_fontsize}")
    @fontname_el.text(fontname)

window.PageEditPanel = PageEditPanel
