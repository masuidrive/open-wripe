/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
class LabeledButton {
  constructor(el) {
    this.el = el;
  }
  label(name) {
    if (name) {
      $('span', this.el).hide();
      this.name = name;
      return $(`span[name=${name}]`, this.el).show();
    } else {
      return this.name;
    }
  }

  click(callback) {
    return this.el.click(callback);
  }

  enable() {
    return this.el.removeClass('disabled');
  }

  disable() {
    return this.el.addClass('disabled');
  }
}


window.LabeledButton = LabeledButton;
