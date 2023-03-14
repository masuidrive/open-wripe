/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require underscore/underscore
//= require backbone/backbone
//= require app/panel
//= require app/markdown_toolbar
//= require models/page
//= require shared/defer
//= require shared/labeled_button
//= require shared/modal_dialog
//= require shared/diff
//= require shared/utils
//= require shared/localstorage
//= require marked/lib/marked
//= require shared/jquery.bootstrap-growl

let sessionStorage;
class LeaveConfirmationDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#page-edit-leave');
  }

  constructor() {
    super();
  }
}
LeaveConfirmationDialog.initClass();

class ConflictDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#page-edit-conflict');
  }

  constructor() {
    super();
  }
}
ConflictDialog.initClass();

class LoadDraftDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#page-edit-load-draft');
  }

  constructor() {
    super();
  }
}
LoadDraftDialog.initClass();

class LoadErrorDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#page-edit-load-error');
  }

  constructor() {
    super();
  }
}
LoadErrorDialog.initClass();

class LoadNotFoundDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#page-edit-load-notfound');
  }

  constructor() {
    super();
  }
}
LoadNotFoundDialog.initClass();

class SaveErrorDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#page-edit-save-error');
  }
  constructor(message) {
    super(SaveErrorDialog)
    $('#page-edit-save-error-label-message').text(message);
  }
}
SaveErrorDialog.initClass();

class DeletePageDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#edit-page-delete');
  }

  constructor() {
    super();
  }
}
DeletePageDialog.initClass();

class DeletePageErrorDialog extends ModalDialog {
  static initClass() {
    this.prototype.el = $('#edit-page-delete-error');
  }

  constructor() {
    super();
  }
}
DeletePageErrorDialog.initClass();


if (is_ios() && is_app()) {
  sessionStorage = window.localStorage;
} else {
  ({
    sessionStorage
  } = window);
}

class PageEditPanel extends AbsolutePanel {
  static initClass() {
    this.el = {
      new_tab: "#navigator-new",
      nav_edit_tab: "#navigator-edit",
      navigator: "#navigator",

      container: "#edit-page-container",
      title: device_type() === "phone" ? "#edit-page-title-phone" : "#edit-page-title",
      body: device_type() === "phone" ? "#edit-page-body-phone" : "#edit-page-body",
      bottom_bar: device_type() === "phone" ? "#edit-page-bottom-bar-phone" : "#edit-page-bottom-bar",
      loading: "#edit-page-loading",

      pane_handle: "#edit-page-pane-handle",
      main_pane: "#edit-page-main-pane",
      sidebar_pane: "#edit-page-sidebar-pane",
      tab_pane: "#edit-page-sidebar-tab-content",
      preview: "#edit-page-preview",
      preview_body: "#edit-page-preview-body",
      preview_wordcount: "#edit-page-preview-wordcount",
      preview_tab: "#edit-page-tab-preview",
      edit_tab: "#edit-page-tab-edit",
      save_button: device_type() === "phone" ? "#edit-page-save-phone" : "#edit-page-save",
      delete_button: "#edit-page-delete-btn",
      autosave_check: "#edit-page-autosave-check",
      fontname: "#edit-fontname",

      hide_after_save: "#help-welcome"
    };
  }

  constructor() {
    super(PageEditPanel);

    this.change_font();

    $('#edit_font_proportional_xlarge').click(() => {
      this.change_font('proportinal', 'xlarge');
    });

    $('#edit_font_proportional_large').click(() => {
      this.change_font('proportinal', 'large');
    });

    $('#edit_font_proportional_medium').click(() => {
      this.change_font('proportinal', 'medium');
    });

    $('#edit_font_proportional_small').click(() => {
      this.change_font('proportinal', 'small');
    });

    $('#edit_font_fixed_xlarge').click(() => {
      this.change_font('fixed', 'xlarge');
    });

    $('#edit_font_fixed_large').click(() => {
      this.change_font('fixed', 'large');
    });

    $('#edit_font_fixed_medium').click(() => {
      this.change_font('fixed', 'medium');
    });

    $('#edit_font_fixed_small').click(() => {
      this.change_font('fixed', 'small');
    });

    this.save_button = new LabeledButton(this.save_button_el);
    this.save_button.el.click(() => this.save());

    this.page = undefined;
    this.lock_version = -1;

    const self = this;
    $('#edit-page-sidebar-tab a').click(function(e) {
      e.preventDefault();
      $(this).tab('show');
      self.resize();
    });

    this.delete_button_el.click(() => {
      return (new DeletePageDialog()).show().done(() => {
        if (this.page && ((this.page.key || '') !== '')) {
          const destroy_defer = this.page.destroy();
          destroy_defer.done(() => {
            this.page = undefined;
            return Backbone.history.navigate('notes', {trigger: true});
          });
          return destroy_defer.fail((error, mesg) => {
            const dialog = new DeletePageErrorDialog();
            dialog.show();
          });
        } else {
          this.page = undefined;
          Backbone.history.navigate('notes', {trigger: true});
        }
      });
    });

    this.autosave_check_el.on('change', () => {
      session.autosave(this.autosave_check_el.prop("checked"));
    });

    session.on('update_autosave', () => {
      this.autosave_check_el.prop("checked", session.autosave());
    });

    setInterval(() => {
      return this.preview();
    }
    , 1000);

    setInterval(() => {
      return this.autosave();
    }
    , 60 * 1000);

    if (device_type() === 'desktop') {
      $(".btn", this.bottom_bar_el).tooltip('hide');
    } else {
      $(".btn", this.bottom_bar_el).tooltip('destroy');
    }

    if (device_type() === 'desktop') {
      const win = $(window);
      this.pane_handle_el.draggable({
        axis: "x",
        drag: (ev, ui) => {
          const w = win.width() - ui.position.left - 90 - 24;
          this.main_pane_el.css('right', `${w}px`);
          return this.sidebar_pane_el.width(w);
        }
      });
    }

    $(window).bind('beforeunload', () => {
      if (this.is_active && this.page && this.is_changed()) {
        return "You have some changes that have not been saved.";
      } else {
        return undefined;
      }
    });
  }

  activate(page) {
    return Deferred(defer => {
      const done = () => {
        this.page.on('update', old_data => {
          const form_is_changed = (old_data.page.title !== this.title_el.val()) || (old_data.page.body !== this.body_el.val());
          if (form_is_changed) {
            return this.merge(this.page.body, old_data.page.body, this.body_el.val(), this.page.lock_version);
          } else {
            $.bootstrapGrowl("Loaded latest version", {type: 'success'});
            return this.page_to_form();
          }
        });
        if (device_type() === 'phone') {
          $('a', this.edit_tab_el).tab('show'); 
        } else {
          $('a', this.preview_tab_el).tab('show'); 
        }
        if (this.page.lock_version === this.lock_version) {
          // todo: merge3
        } else {
          this.page_to_form(); 
        }
        this.loading_el.hide();
        this.body_el.focus();
        return defer.resolve();
      };

      if (page) {
        this.edit_tab_el.tab('show');
      } else {
        this.new_tab_el.tab('show');
      }

      this.form_clear();
      if (device_type() !== 'phone') { this.resize(); }

      this.loading_el.show();
      if ((typeof page) === 'string') {
        this.page = new Page();
        this.page.key = page;
        this.load_draft();
        const load_defer = this.page.load(page);
        load_defer.always(() => this.loading_el.hide());
        load_defer.done(() => done());
        return load_defer.fail((error_type, error_message, error_object) => {
          if (error_type === 'notfound') {
            this.page = new Page();
            this.page_to_form();
            (new LoadNotFoundDialog()).show().always(() => {
              return delay(100, () => this.body_el.focus());
            });
            return defer.resolve();
          } else {
            (new LoadErrorDialog()).show();
            return defer.reject(error_type, error_message, error_object);
          }
        });
      } else {
        this.page = page || new Page();
        this.load_draft();
        return done();
      }
    });
  }

  deactivate() {
    return Deferred(defer => {
      this.form_to_page();
      if (this.page && this.page.is_changed()) {
        const dialog = new LeaveConfirmationDialog();
        const dialog_defer = dialog.show();
        dialog_defer.done(() => {
          this.container_el.hide();
          this.clear_draft();
          this.navigator_el.show();
          return defer.resolve();
        });
        return dialog_defer.fail(() => {
          delay(100, () => this.body_el.focus());
          return defer.reject();
        });
      } else {
        this.container_el.hide();
        this.clear_draft();
        this.navigator_el.show();
        return defer.resolve();
      }
    });
  }

  focus() {
    if (this.page && !this.page.request) { return this.page.check_update(); }
  }

  form_clear() {
    if (device_type() === 'phone') {
      this.edit_tab_el.tab('show');
    } else {
      this.preview_tab_el.tab('show');
    }
    this.title_el.val('');
    this.body_el.val('');
    this.lock_version = -1;
    this.save_button.label('save');
    this.preview_body_el.html('');
    this.preview_wordcount_el.html('');
    return this.previewed_body = '';
  }

  page_to_form() {
    if (this.page && (this.page.lock_version !== this.lock_version)) {
      this.title_el.val(this.page.title);
      this.body_el.val(this.page.body);
      this.lock_version = this.page.lock_version;
      return this.preview();
    }
  }

  form_to_page() {
    if (this.page) {
      this.page.title = this.title_el.val();
      this.page.body = this.body_el.val();
      this.page.lock_version = this.lock_version;
      return this.save_draft();
    }
  }

  is_changed() {
    return this.page && ( (this.page.saved_data.body !== this.body_el.val()) || (this.page.saved_data.title !== this.title_el.val()) );
  }

  save() {
    if (this.is_active && !ModalDialog.is_active()) {
      return Deferred(defer => {
        if (this.save_button.label() === 'saving') {
          return defer.reject();
        } else {
          this.save_button.label('saving');
          this.form_to_page();
          const save_defer = this.page.save();

          save_defer.always(() => {
            return this.save_button.label('save');
          });

          save_defer.done(() => {
            if (this.page && (this.page.lock_version === (this.lock_version+1))) {
              this.page.title = this.title_el.val();
              this.page.body = this.body_el.val();
              this.lock_version = this.page.lock_version;
            } else {
              this.page_to_form();
            }
            Backbone.history.navigate(`${this.page.key}/edit`, {trigger: false});
            $.bootstrapGrowl("Saved", {type: 'success'});
            this.hide_after_save_el.empty();
            defer.resolve();
            return analytics.event({ev: 'Edit', ea: 'Save'});
          });

          return save_defer.fail((error, option1) => {
            if (error === 'conflict') {
              this.merge(this.body_el.val(), this.page.saved_data.body, option1.body, option1.lock_version);
            } else {
              const dialog = new SaveErrorDialog(option1);
              dialog.show().always(() => {
                return delay(100, () => this.body_el.focus());
              });
            }
            return defer.reject();
          });
        }
      });
    }
  }

  merge(a, o, b, lock_version) {
    const current_body = a.replace("\r", '').split(/\n/);
    const saved_body = o.replace("\r", '').split(/\n/);
    const server_body = b.replace("\r", '').split(/\n/);
    const merged = Diff.diff3_merge(current_body, saved_body, server_body);
    
    let merged_text = '';
    merged.forEach(function(block) {
      if (block.ok) {
        return block.ok.forEach(line => merged_text += `${line}\n`);
      } else if (block.conflict) {
        block.conflict.a.forEach(line => merged_text += `${line}\n`);
        block.conflict.o.forEach(function(line) {});
          // merged_text += "#{line}\n" 
        return block.conflict.b.forEach(line => merged_text += `${line}\n`);
      }
    });

    const body_el = this.body_el.get(0);
    const cur = body_el.selectionStart;

    this.body_el.val(merged_text);
    this.lock_version = (this.page.lock_version = lock_version);
    (new ConflictDialog()).show().always(() => {
      return delay(100, () => {
        this.body_el.focus();
        body_el.selectionStart = cur;
        return body_el.selectionEnd = cur;
      });
    });
    return analytics.event({ev: 'Edit', ea: 'MergeDialog'});
  }

  preview() {
    if (this.is_active) {
      this.save_draft();
      const body = this.body_el.val();
      if (this.previewed_body !== body) {
        let words;
        this.previewed_body = body;
        const tokens = marked.lexer(this.previewed_body);
        this.preview_body_el.html(`<div class=\"content\">${marked.parser(tokens)}</div>`);

        // word counter
        const chars_m = body.match(/[^\u0000-\u0020]/g);
        const chars = chars_m ? chars_m.length : 0;
        if (body.trim() === '') {
          words = 0;
        } else {
          words = body.trim().split(/\s+/g).length;
        }
        const lines_m = body.trim().match(/[\r\n]+/g); 
        const lines = lines_m ? lines_m.length : 0;
        return this.preview_wordcount_el.html(`C: <strong>${chars}</strong>, W: <strong>${words}</strong>, L: <strong>${lines}</strong>`);
      }
    }
  }

  resize() { 
    this.container_el.show();
    this.full_height(this.body_el, this.bottom_bar_el.height() + (device_type() === 'phone' ? 0 : 4) + 16 + 6);
    this.full_height(this.sidebar_pane_el, (device_type() === 'phone' ? 2 : 8));
    this.full_height(this.tab_pane_el, (device_type() === 'phone' ? 2 : 9));
    this.full_height(this.loading_el, 2);
    return this.pane_handle_el.css('left', $(window).width()-this.sidebar_pane_el.width() - 90 - 24);
  }

  hotkeys(ev, keychar) {
    const keycode2char = {
      0x09: "\t",
      0x20: " ",
      0xbd: "-"
    };

    if (ev.shiftKey && (ev.ctrlKey || ev.metaKey || ev.altKey)) {
      switch (keychar) {
        case 'I':
          ev.preventDefault();
          return Backbone.history.navigate('notes', {trigger: true});

        case 'T':
          ev.preventDefault();
          if (markdownToolbar) { return markdownToolbar.insertToday(); }
          break;
      }

    } else if (ev.ctrlKey || ev.metaKey || ev.altKey) {
      switch (keychar) {
        case 'S':
          ev.preventDefault();
          return this.save();
      }

    } else if (ev.shiftKey && !ev.ctrlKey && !ev.metaKey && !ev.altKey) {
      switch (ev.keyCode) {
        case 0x09: case 0x20: case 0xbd: // tab-key, space, -
          if ($(':focus').attr('id') === 'edit-page-body') {
            if (this.body_el.isTextSelected()) {
              ev.preventDefault();
              return this.body_el.removeToSelection(keycode2char[ev.keyCode]);
            }
          }
          break;
      }

    } else if (!ev.shiftKey && !ev.ctrlKey && !ev.metaKey && !ev.altKey) {
      switch (ev.keyCode) {
        case 0x09: case 0x20: case 0xbd: // tab-key, space, -
          if ($(':focus').attr('id') === 'edit-page-body') {
            if (this.body_el.isTextSelected()) {
              ev.preventDefault();
              return this.body_el.insertToSelection(keycode2char[ev.keyCode]);
            } else {
              if (markdownToolbar && (ev.keyCode === 0x09)) {
                ev.preventDefault();
                return markdownToolbar.insertTab();
              }
            }
          }
          break;
      }
    }
  }

  load_draft() { 
    const draft_key = sessionStorage['page-edit-key'];
    if (typeof draft_key !== 'undefined') {
      const draft_body = sessionStorage['page-edit-body'];
      const draft_title = sessionStorage['page-edit-title'];
      const draft_lock_version = sessionStorage['page-edit-lock-version'];

      if (this.page && ((this.page.key || '') === draft_key)) {
        const use_draft = () => {
          this.body_el.val(this.page.body = draft_body);
          this.title_el.val(this.page.title = draft_title);
          return this.lock_version = draft_lock_version==='' ? undefined : parseInt(draft_lock_version);
        };

        if (is_app()) {
          delay(500, () => this.body_el.focus());
          return use_draft();
        } else {
          const defer = (new LoadDraftDialog()).show();
          defer.always(() => {
            return delay(500, () => this.body_el.focus());
          });
          defer.done(() => {
            return use_draft();
          });
          return defer.fail(() => {
            return this.clear_draft();
          });
        }
      }
    }
  }

  save_draft() {
    if (this.is_active) {
      if (this.page && ((this.body_el.val() !== this.page.saved_data.body) || (this.title_el.val() !== this.page.saved_data.title))) {
        sessionStorage['page-edit-key'] = this.page.key || '';
        sessionStorage['page-edit-body'] = this.body_el.val();
        sessionStorage['page-edit-title'] = this.title_el.val();
        return sessionStorage['page-edit-lock-version'] = this.page.lock_version || '';
      } else {
        return this.clear_draft();
      }
    }
  }

  clear_draft() {
    sessionStorage.removeItem('page-edit-key');
    sessionStorage.removeItem('page-edit-body');
    sessionStorage.removeItem('page-edit-title');
    return sessionStorage.removeItem('page-edit-lock-version');
  }

  autosave() {
    if (this.page && session.autosave() && !ModalDialog.is_active()) {
      const data = this.page.saved_data || { body: this.page.body, title: this.page.title };
      if ((data.body !== this.body_el.val()) || (data.title !== this.title_el.val())) {
        return this.save();
      }
    }
  }

  change_font(fontname, fontsize) {
    if (!fontname) { fontname = localStorage.editor_fontname || 'proportinal'; }
    if (!fontsize) { fontsize = localStorage.editor_fontsize || 'small'; }

    this.fontname_el.removeClass(`edit_fontname_${localStorage.editor_fontname}`);
    this.body_el.removeClass(`edit_fontname_${localStorage.editor_fontname}`);
    this.body_el.removeClass(`edit_fontsize_${localStorage.editor_fontsize}`);
    localStorage.editor_fontname = fontname;
    localStorage.editor_fontsize = fontsize;
    this.fontname_el.addClass(`edit_fontname_${localStorage.editor_fontname}`);
    this.body_el.addClass(`edit_fontname_${localStorage.editor_fontname}`);
    this.body_el.addClass(`edit_fontsize_${localStorage.editor_fontsize}`);
    return this.fontname_el.text(fontname);
  }
}
PageEditPanel.initClass();

window.PageEditPanel = PageEditPanel;
