#= require shared/utils
#= require shared/modal_dialog

class InsetLinkDialog extends ModalDialog
  el: $('#edit-page-insert-link')
  title_el: $('#edit-page-insert-link-text')
  url_el: $('#edit-page-insert-link-url')
  focus_el: $('#edit-page-body')

  shown: ->
    delay 500, => @title_el.focus()

  action: (action) ->
    if action == 'link'
      markdownToolbar.insertTemplate("[#{@title_el.val()}](#{@url_el.val()})")
      delay 300, => @focus_el.focus() if @focus_el


insertTextAtPosision = (obj, pos, txt, start_idx, end_idx) ->
  obj.focus()
  if (document.uniqueID) # if IE
    pos.text = txt;
    pos.select()
  else
    pos = 0 if pos < 0
    s = obj.value
    np = pos + txt.length
    obj.value = s.substr(0, pos) + txt + s.substr(pos)
    if typeof start_idx == 'undefined'
      start_idx = 0
    if typeof end_idx == 'undefined'
      end_idx = 0;
    obj.setSelectionRange(start_idx + np, end_idx + np)


getCaretPosition = (obj) ->
  obj.focus()
  if document.uniqueID then document.selection.createRange() else obj.selectionStart


class MarkdownToolbar
  el: $('#edit-page-body')

  insertLink: ->
    dialog = new InsetLinkDialog()
    dialog.show()

  insertTemplate: (text, start_idx, end_idx) ->
    head = getCaretPosition(@el[0])

    if text.substring(0,1) == "\n"
      text = text.substring(1)
      body = @el.val()
      if body.substring(head, head+1) == "\n"
        --head;
      while head > 0
        if body.substring(head, head + 1) == "\n"
          insertTextAtPosision(@el[0], head + 1, text, start_idx, end_idx)
          return
        --head
    insertTextAtPosision(@el[0], head, text, start_idx, end_idx)

  insertToday: () ->
    insertTextAtPosision(@el[0], getCaretPosition(@el[0]), today_string())

  insertTab: () ->
    insertTextAtPosision(@el[0], getCaretPosition(@el[0]), "\t")

window.markdownToolbar = new MarkdownToolbar()
