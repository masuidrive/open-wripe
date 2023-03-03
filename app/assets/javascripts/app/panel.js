/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require underscore/underscore
//= require backbone/backbone
//= require shared/defer
//= require bootstrap2/docs/assets/js/bootstrap

class AbsolutePanel {
  constructor(klass) {
    _.extend(this, Backbone.Events);
    this.compiled_template = {};

    if (klass && klass.el) {
      for (var name in klass.el) {
        var selector = klass.el[name];
        this[`${name}_el`] = $(selector);
      }
    }
  }

  activate() {
    return Deferred(defer => {
      return defer.resolve();
    });
  }

  deactivate() {
    return Deferred(defer => {
      return defer.resolve();
    });
  }

  reactivate() {
    return this.activate();
  }

  resize() {}

  hotkeys(ev) {}

  // protected
  template(name, obj) {
    if (!this.compiled_template[name]) {
      this.compiled_template[name] = _.template($("#"+name).html());
    }
    return this.compiled_template[name](obj);
  }

  full_height(el, bottom, height_el, recur) {
    if (!height_el) { height_el = el; }
    const offset = height_el.offset();
    const h = (window_height() - offset.top - (bottom || 0));
    el.height(h);
    if (!recur) {
      return delay(100, () => {
        if (el.height() !== h) {
          this.full_height(el, bottom, height_el, true);
        }
      });
    }
  }
}

_.templateSettings = {
  evaluate  : /{%([\s\S]+?)%}/g,
  interpolate : /\${raw ([\s\S]+?)}/g,
  escape    : /\${([\s\S]+?)}/g
};

window.AbsolutePanel = AbsolutePanel;
