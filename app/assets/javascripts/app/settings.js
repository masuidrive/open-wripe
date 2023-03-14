/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require underscore/underscore
//= require backbone/backbone
//= require models/page
//= require shared/defer
//= require shared/labeled_button
//= require shared/modal_dialog
//= require bootstrap-switch/dist/js/bootstrap-switch

class ExportNotesDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#settings-export');
  }

  constructor() {
    super();
  }

  action(name) {
    if (name === 'download') {
      location.href = '/export/zip';
    }
  }
}
ExportNotesDialog.initClass();

class BackupSettingsDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#settings-backup');
    this.prototype.turned_on_el = $('#settings-backup-dropbox-turnedon');
    this.prototype.turned_on_btn_el = $('#settings-backup-dropbox-turnon-button');
    this.prototype.turned_off_el = $('#settings-backup-dropbox-turnedoff');
    this.prototype.turned_off_btn_el = $('#settings-backup-dropbox-turnoff-button');
    this.prototype.processing_el = $('#settings-backup-dropbox-processing');
    this.prototype.sign_in_url = '/dropbox_auth/sign_in';
  }

  constructor() {
    super();
    this.turned_on_btn_el.click(e => {
      this.processing_el.show();
      this.turned_on_el.hide();
      this.turned_off_el.hide();
      this.auth();
    });

    this.turned_off_btn_el.click(e => {
      this.processing_el.show();
      this.turned_on_el.hide();
      this.turned_off_el.hide();
      const defer = this.request_turn_off();
      defer.always(data => {
        this.processing_el.hide();
      });
      defer.done(data => {
        this.turned_on_el.hide();
        this.turned_off_el.show();
      });
      return defer.fail(check_auth);
    });
  }

  shown() {
    this.processing_el.hide();
    this.turned_on_el.hide();
    this.turned_off_el.hide();
    this.update_status();
  }

  update_status() {
    const defer = authorizedRequest({url: "/settings.json"});
    defer.done(data => {
      this.processing_el.hide();
      if (data.use_dropbox) {
        this.turned_on_el.show();
      } else {
        this.turned_off_el.show();
      }
    });
    return defer.fail(check_auth);
  }

  auth() {
    this.window = window.open(this.sign_in_url, 'wripe_auth');
    if (this.timer) { clearInterval(this.timer); }
    return this.timer = setInterval(() => {
      this.check_window();
    }
    , 1000);
  }

  check_window() {
    if (this.window && this.window.closed) {
      this.window = undefined;
      if (this.timer) { clearInterval(this.timer); }
      this.timer = undefined;
      return this.update_status();
    }
  }

  hidden() {
    if (this.timer) { clearInterval(this.timer); }
    this.timer = undefined;
    this.processing_el.hide();
    this.turned_on_el.hide();
    this.turned_off_el.hide();
  }

  request_turn_off() {
    return authorizedRequest({url: "/settings.json", type: 'PUT', data: { use_dropbox: false }});
  }
}
BackupSettingsDialog.initClass();


class EvernoteSettingsDialog extends BackupSettingsDialog {
  static initClass() {
    this.prototype.el = $('#settings-evernote');
    this.prototype.turned_on_el = $('#settings-evernote-turnedon');
    this.prototype.turned_on_btn_el = $('#settings-evernote-turnon-button');
    this.prototype.turned_off_el = $('#settings-evernote-turnedoff');
    this.prototype.turned_off_btn_el = $('#settings-evernote-turnoff-button');
    this.prototype.processing_el = $('#settings-evernote-processing');
    this.prototype.sign_in_url = '/evernote_auth/connect';
  }

  update_status() {
    const defer = authorizedRequest({url: "/settings.json"});
    defer.done(data => {
      this.processing_el.hide();
      if (data.use_evernote) {
        this.turned_on_el.show();
      } else {
        this.turned_off_el.show();
      }
    });
    return defer.fail(check_auth);
  }


  request_turn_off() {
    return authorizedRequest({url: "/settings.json", type: 'PUT', data: { use_evernote: false }});
  }
}
EvernoteSettingsDialog.initClass();

$(function() {
  const export_dialog = new ExportNotesDialog();
  $('#settings-export-button').click(() => export_dialog.show());

  const evernote_dialog = new EvernoteSettingsDialog();
  $('#help-evernote-button').click(() => evernote_dialog.show());
  $('#settings-evernote-button').click(() => evernote_dialog.show());

  const backup_dialog = new BackupSettingsDialog();
  $('#settings-backup-button').click(() => backup_dialog.show());
  $('#settings-backup-button-in-export').click(() => backup_dialog.show());
  $('#help-backup-button').click(() => backup_dialog.show());
});

