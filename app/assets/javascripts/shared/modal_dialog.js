/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require underscore/underscore
//= require backbone/backbone


class ModalDialog {
  static initClass() {
    this.modal_counter = 0;
  }
  constructor(options) {
    _.extend(this, Backbone.Events);
    if (!options) { options = { show: false }; }
    this.el.unbind('show');
    this.el.on('show', () => {
      ModalDialog.modal_counter += 1;
      this.shown();
    });
    this.el.unbind('hide');
    this.el.on('hide', e => {
      ModalDialog.modal_counter -= 1;
      this.hidden();
      if (this.defer) {
        this.defer.reject();
        this.defer = undefined;
      }
    });

    const actions = $("*[data-action]", this.el);
    actions.unbind('click');
    actions.click(ev => {
      ev.preventDefault();
      if (this.defer) {
        const action_name = $(ev.currentTarget).attr('data-action');
        this.action(action_name);
        this.defer.resolve(action_name);
        this.defer = undefined;
        this.hide();
      }
    });

    this.el.modal(options);
  }

  static is_active() {
    return this.modal_counter > 0;
  }

  show() {
    return Deferred(defer => {
      this.defer = defer;
      this.will_show();
      this.el.modal('show');
    });
  }

  hide() {
    this.will_hide();
    this.el.modal('hide');
  }

  action(name) {}
    // please override

  will_show() {}
    // please override

  shown() {}
    // please override

  will_hide() {}
    // please override

  hidden() {}
}
ModalDialog.initClass();
    // please override


window.ModalDialog = ModalDialog;
