/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require underscore/underscore
//= require backbone/backbone
//= require app/panel
//= require models/page
//= require models/page_collection
//= require shared/defer
//= require shared/labeled_button
//= require shared/relative_date
// require shared/iscroll

class PageListPanel extends AbsolutePanel {
  static initClass() {
    this.el = {
      'header_title': '#list-page-header-title',
      'welcome': "#help-welcome",
      'auto_loading': "#list-page-auto-loading"
    };
  }

  constructor(tab_el, tab_name, title, root_url) {
    super(PageListPanel);
    this.tab_el = tab_el;
    this.tab_name = tab_name;
    this.title = title;
    this.root_url = root_url;
    this.container_el = $('#list-page-container');
    this.list_el = $('#list-page');
    this.pageno_el = $('#list-page-pageno');
    this.loading_el = $('#list-page-loading');
    this.loading_error_el = $('#list-page-loading-error');
    this.loading_error_text_el = $('#list-page-loading-error-text');
    this.empty_message_el = $('#list-page-empty');
    this.sidebar_el = $('#list-page-sidebar-pane');
    this.list_wrapper_el = $('#list-page-wrapper');

    this.loading_collection = undefined;
    this.collection = undefined;

    // monitor position for auto load
    setInterval(() => {
      if (this.is_active) {
        if ($("#list-page-auto-loading").offset().top < (window_height() * 2)) {
          return this.load_old_page();
        }
      }
    }
    , 100);

    if (this.tab_name === 'notes') {
      const request = authorizedRequest({url: "/pages/tags.json", type: 'GET'});
      request.done(data => {
        let html = '';
        for (let tag of data) {
          html += `<a href=\"#notes/${encodeURIComponent(tag.name)}\">${escape_html(tag.name)}</a> `;
        }
        return $("#list-page-sidebar-tags .body").html(html);
      });
    }
  }

  activate(tag) {
    this.tag = tag;
    return Deferred(defer => {
      this.tab_el.tab('show');
      this.welcome_el.hide();

      const title = this.tag ? `${this.title} / ${this.tag}` : this.title;
      this.header_title_el.html(title);
      this.cursor = 0;
      this.container_el.addClass(`list-page-${this.tab_name}`);
      this.container_el.show();
      this.clear();
      this.list_wrapper_el.scrollTop(0);

      let url = this.root_url;
      if (this.tag) {
        url += this.tag.indexOf('?') > -1 ? '&' : '?';
        url += `tag=${encodeURIComponent(this.tag)}`;
      }

      const load_defer = this.load(new PageCollection(url));

      if (this.tab_name === 'notes') {
        local_session(data => {
          return load_defer.done(() => {
            if ((data.pages_count === 0) && (this.collection.pages.length === 0)) {
              return this.welcome_el.show();
            }
          });
        });
      }
      return defer.resolve();
    });
  }

  deactivate() {
    return Deferred(defer => {
      if (this.loading_collection) { this.loading_collection.abort(); }
      if (this.collection) { this.collection.abort(); }
      this.welcome_el.hide();
      this.container_el.hide();
      this.container_el.removeClass(`list-page-${this.tab_name}`);
      this.empty_message_el.hide();
      return defer.resolve();
    });
  }

  clear() {
    this.collection = undefined;
    this.pageno_el.html('');
    this.list_el.html('');
    this.loading_error_el.hide();
    this.loading_el.hide();
    return this.empty_message_el.hide();
  }

  render() {
    this.empty_message_el.hide();
    this.loading_error_el.hide();
    this.loading_el.hide();
    this.auto_loading_el.hide();
    this.list_el.html('');
    if (this.collection) {
      if (this.collection.pages.length > 0) {
        this.pageno_el.text(`${this.collection.total_pages} ${this.collection.total_pages > 1 ? 'pages' : 'page'}`);
        return (() => {
          const result = [];
          for (let i = 0; i <= this.collection.pages.length-1; i++) {
            var page = $.extend({}, this.collection.pages[i]);
            page.cursor = (this.cursor === i);
            this.list_el.append(this.template('list-page-template', page));
            $("#list-page-archive-"+page.key).click(e => {
              e.preventDefault();
              return this.archive($(e.currentTarget).attr('key'));
            });
            result.push($("#list-page-unarchive-"+page.key).click(e => {
              e.preventDefault();
              return this.unarchive($(e.currentTarget).attr('key'));
            }));
          }
          return result;
        })();
      } else {
        if (this.tab_name === 'archived') { return this.empty_message_el.show(); }
      }
    }
  }

  archive(page_key) {
    $(`#list-page-moving-${page_key}`).show();
    $(`#list-page-archive-${page_key}`).hide();
    $(`#list-page-unarchive-${page_key}`).hide();
    const page = this.page_by_key(page_key);
    const defer = page.archive();
    defer.always(() => {
      return $(`#list-page-moving-${page_key}`).hide();
    });
    return defer.done(() => {
      $(`#list-page-unarchive-${page_key}`).show();
      return $.bootstrapGrowl("Archived", {type: 'success', delay:2000});
    });
  }

  unarchive(page_key) {
    $(`#list-page-moving-${page_key}`).show();
    $(`#list-page-archive-${page_key}`).hide();
    $(`#list-page-unarchive-${page_key}`).hide();
    const page = this.page_by_key(page_key);
    const defer = page.unarchive();
    defer.always(() => {
      return $(`#list-page-moving-${page_key}`).hide();
    });
    return defer.done(() => {
      $(`#list-page-archive-${page_key}`).show();
      return $.bootstrapGrowl("Move to Notes", {type: 'success', delay:2000});
    });
  }

  load(collection) {
    this.loading_el.show();
    this.loading_error_el.hide();
    if (this.loading_collection) { this.loading_collection.abort(); }
    this.loading_collection = collection;
    this.loading_collection.on('update', () => {
      return this.render();
    });
    const load_defer = this.loading_collection.load(true);
    load_defer.always(() => {
      this.loading_el.hide();
      return this.empty_message_el.hide();
    });
    load_defer.done(() => {
      this.collection = this.loading_collection;
      this.loading_collection = undefined;
      return this.render();
    });
    load_defer.fail(error => {
      this.loading_collection = undefined;
      this.loading_error_text_el.text(error);
      return this.loading_error_el.show();
    });
    return load_defer;
  }

  load_old_page() {
    if (this.old_collection || !this.collection) { return; }
    this.old_collection = this.collection.old_collection();
    if (this.old_collection) {
      this.auto_loading_el.show();
      const load_defer = this.old_collection.load();
      load_defer.done(() => {
        this.collection.append(this.old_collection);
        return this.render();
      });
      load_defer.fail(error => {
        this.loading_error_text_el.text(error);
        this.loading_error_el.show();
        return setTimeout(() => {
          return this.load_old_page;
        }
        , 3 * 1000);
      });
      return load_defer.always(() => {
        this.old_collection = undefined;
        return this.auto_loading_el.hide();
      });
    }
  }

  page_by_key(page_key) {
    for (var page of this.collection.pages) {
      if (page.key === page_key) { return page; }
    }
    return undefined;
  }

  cursor_move(idx) {
    if (typeof idx !== 'undefined') { this.cursor = idx; }
    $("#list-page>.page").removeClass('cursor');
    $(`#list-page .page:nth-child(${this.cursor+1})`).addClass('cursor');
    const cur = $("#list-page .cursor");
    const bottom = 32;
    if ((cur.length > 0) && (cur.offset().top < $("#list-page-wrapper").offset().top)) {
      return $("#list-page-wrapper").scrollTop(($("#list-page").offset().top * -1) + cur.offset().top);
    } else if ((cur.length > 0) && ((cur.offset().top + cur.height() + bottom) > ($("#list-page-wrapper").offset().top + $("#list-page-wrapper").height()))) {
      const top = ((-1*$("#list-page").offset().top)+cur.offset().top+$("#list-page-wrapper").offset().top)-$("#list-page-wrapper").height();
      return $("#list-page-wrapper").scrollTop(top + bottom);
    }
  }

  cursor_enter() {
    if (typeof this.cursor !== 'undefined') {
      const href = $(`#list-page .page:nth-child(${this.cursor+1}) .title a`).attr('href');
      return Backbone.history.navigate(href, {trigger:true}); 
    }
  }

  cursor_archive() {
    if (typeof this.cursor !== 'undefined') {
      const page_key = $(`#list-page .page:nth-child(${this.cursor+1})`).attr('name');
      const page = this.page_by_key(page_key);
      if (page.archived) {
        return this.unarchive(page_key);
      } else {
        return this.archive(page_key);
      }
    }
  }

  cursor_up() {
    if (this.cursor > 0) { return this.cursor_move(this.cursor - 1); }
  }

  cursor_down() {
    if (this.cursor < (this.collection.pages.length - 1)) { return this.cursor_move(this.cursor + 1); }
  }

  resize() {
    this.container_el.show();
    this.full_height(this.container_el, 0);
    this.full_height(this.list_wrapper_el, 0);
    return this.full_height(this.sidebar_el, 0);
  }

  hotkeys(ev, keychar) {
    const key_func = () => {
      switch (keychar) {
        case 'E':
          ev.preventDefault();
          return this.cursor_archive();
        case 'N':
          ev.preventDefault();
          return Backbone.history.navigate('new', {trigger: true});
        case 'I':
          ev.preventDefault();
          return Backbone.history.navigate('notes', {trigger: true});
        case 'D':
          ev.preventDefault();
          return Backbone.history.navigate('archived', {trigger: true});
        case 'C':
          ev.preventDefault();
          return Backbone.history.navigate('calendar', {trigger: true});
        case 'S':
          ev.preventDefault();
          return Backbone.history.navigate('search', {trigger: true});
        case 'J':
            ev.preventDefault();
            return this.cursor_down();
        case 'K':
            ev.preventDefault();
            return this.cursor_up();
        case 'O':
            ev.preventDefault();
            return this.cursor_enter();
      }
    };

    const el = (document.activeElement.tagName || '').toUpperCase();
    if ((el !== 'INPUT') && (el !== 'TEXTAREA')) {
      key_func();
      switch (ev.keyCode) {
        case 38: // up
          ev.preventDefault();
          return this.cursor_up();
        case 40: // down
          ev.preventDefault();
          return this.cursor_down();
        case 13: // enter
          ev.preventDefault();
          return this.cursor_enter();
      }
    } else if (ev.ctrlKey || ev.metaKey || ev.altKey) {
      return key_func();
    }
  }
}
PageListPanel.initClass();

window.PageListPanel = PageListPanel;
