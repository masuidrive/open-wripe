/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require shared/utils
//= require shared/modal_dialog

class InsetLinkDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#edit-page-insert-link');
    this.prototype.title_el = $('#edit-page-insert-link-text');
    this.prototype.url_el = $('#edit-page-insert-link-url');
    this.prototype.focus_el = $('#edit-page-body');
  }

  shown() {
    delay(500, () => this.title_el.focus());
  }

  action(action) {
    if (action === 'link') {
      markdownToolbar.insertTemplate(`[${this.title_el.val()}](${this.url_el.val()})`);
      delay(300, () => { if (this.focus_el) { return this.focus_el.focus(); } });
    }
  }
}
InsetLinkDialog.initClass();


const insertTextAtPosision = function(obj, pos, txt, start_idx, end_idx) {
  obj.focus();
  if (document.uniqueID) { // if IE
    pos.text = txt;
    pos.select();
  } else {
    if (pos < 0) { pos = 0; }
    const s = obj.value;
    const np = pos + txt.length;
    obj.value = s.substr(0, pos) + txt + s.substr(pos);
    if (typeof start_idx === 'undefined') {
      start_idx = 0;
    }
    if (typeof end_idx === 'undefined') {
      end_idx = 0;
    }
    obj.setSelectionRange(start_idx + np, end_idx + np);
  }
};


const getCaretPosition = function(obj) {
  obj.focus();
  if (document.uniqueID) { return document.selection.createRange(); } else { return obj.selectionStart; }
};


class MarkdownToolbar {
  static initClass() {
    this.prototype.el = $('#edit-page-body');
  }

  insertLink() {
    const dialog = new InsetLinkDialog();
    dialog.show();
  }

  insertTemplate(text, start_idx, end_idx) {
    let head = getCaretPosition(this.el[0]);

    if (text.substring(0,1) === "\n") {
      text = text.substring(1);
      const body = this.el.val();
      if (body.substring(head, head+1) === "\n") {
        --head;
      }
      while (head > 0) {
        if (body.substring(head, head + 1) === "\n") {
          insertTextAtPosision(this.el[0], head + 1, text, start_idx, end_idx);
          return;
        }
        --head;
      }
    }
    insertTextAtPosision(this.el[0], head, text, start_idx, end_idx);
  }

  insertToday() {
    insertTextAtPosision(this.el[0], getCaretPosition(this.el[0]), today_string());
  }

  insertTab() {
    insertTextAtPosision(this.el[0], getCaretPosition(this.el[0]), "\t");
  }
}
MarkdownToolbar.initClass();

window.markdownToolbar = new MarkdownToolbar();
