/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */

class SplashDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#splash-dialog');
  }
}
SplashDialog.initClass();

window.SplashDialog = SplashDialog;