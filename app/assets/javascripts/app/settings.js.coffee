#= require underscore/underscore
#= require backbone/backbone
#= require models/page
#= require shared/defer
#= require shared/labeled_button
#= require shared/modal_dialog
#= require bootstrap-switch/dist/js/bootstrap-switch

class ExportNotesDialog extends ModalDialog
  el: $('#settings-export')

  action: (name) ->
    if name == 'download'
      location.href = '/export/zip'

class BackupSettingsDialog extends ModalDialog
  el: $('#settings-backup')
  turned_on_el: $('#settings-backup-dropbox-turnedon')
  turned_on_btn_el: $('#settings-backup-dropbox-turnon-button')
  turned_off_el: $('#settings-backup-dropbox-turnedoff')
  turned_off_btn_el: $('#settings-backup-dropbox-turnoff-button')
  processing_el: $('#settings-backup-dropbox-processing')
  sign_in_url: '/dropbox_auth/sign_in'

  constructor: ->
    super()
    @turned_on_btn_el.click (e) =>
      @processing_el.show()
      @turned_on_el.hide()
      @turned_off_el.hide()
      @auth()

    @turned_off_btn_el.click (e) =>
      @processing_el.show();
      @turned_on_el.hide();
      @turned_off_el.hide();
      defer = @request_turn_off()
      defer.always (data) =>
        @processing_el.hide()
      defer.done (data) =>
        @turned_on_el.hide()
        @turned_off_el.show()
      defer.fail(check_auth)

  shown: ->
    @processing_el.hide()
    @turned_on_el.hide()
    @turned_off_el.hide()
    @update_status()

  update_status: ->
    defer = authorizedRequest(url: "/settings.json")
    defer.done (data) =>
      @processing_el.hide()
      if data.use_dropbox
        @turned_on_el.show();
      else
        @turned_off_el.show();
    defer.fail(check_auth)

  auth: ->
    @window = window.open(@sign_in_url, 'wripe_auth')
    clearInterval @timer if @timer
    @timer = setInterval () =>
      @check_window()
    , 1000

  check_window: ->
    if @window && @window.closed
      @window = undefined
      clearInterval @timer if @timer
      @timer = undefined
      @update_status()

  hidden: ->
    clearInterval @timer if @timer
    @timer = undefined
    @processing_el.hide()
    @turned_on_el.hide()
    @turned_off_el.hide()

  request_turn_off: ->
    authorizedRequest(url: "/settings.json", type: 'PUT', data: { use_dropbox: false })


class EvernoteSettingsDialog extends BackupSettingsDialog
  el: $('#settings-evernote')
  turned_on_el: $('#settings-evernote-turnedon')
  turned_on_btn_el: $('#settings-evernote-turnon-button')
  turned_off_el: $('#settings-evernote-turnedoff')
  turned_off_btn_el: $('#settings-evernote-turnoff-button')
  processing_el: $('#settings-evernote-processing')
  sign_in_url: '/evernote_auth/connect'

  update_status: ->
    defer = authorizedRequest(url: "/settings.json")
    defer.done (data) =>
      @processing_el.hide()
      if data.use_evernote
        @turned_on_el.show();
      else
        @turned_off_el.show();
    defer.fail(check_auth)


  request_turn_off: ->
    authorizedRequest(url: "/settings.json", type: 'PUT', data: { use_evernote: false })

$ ->
  export_dialog = new ExportNotesDialog()
  $('#settings-export-button').click ->
    export_dialog.show()

  evernote_dialog = new EvernoteSettingsDialog()
  $('#help-evernote-button').click ->
    evernote_dialog.show()
  $('#settings-evernote-button').click ->
    evernote_dialog.show()

  backup_dialog = new BackupSettingsDialog()
  $('#settings-backup-button').click ->
    backup_dialog.show()
  $('#settings-backup-button-in-export').click ->
    backup_dialog.show()
  $('#help-backup-button').click ->
    backup_dialog.show()

