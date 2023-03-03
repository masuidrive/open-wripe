/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require jquery/dist/jquery
//= require jquery-ui/dist/jquery-ui
//= require bootstrap2/docs/assets/js/bootstrap
//= require underscore/underscore
//= require backbone/backbone
//= require shared/utils
//= require shared/app_cache
//= require shared/feedback
//= require shared/analytics
//= require iscroll/src/iscroll-lite
//= require konami
//= require_tree ./app

// shared/sprintf.js (https://github.com/azatoth/jquery-sprintf)
// konami.js (https://github.com/georgemandis/konami-js)

class AppRouter extends Backbone.Router {
  static initClass() {
    this.prototype.routes = {
      "": "index",
      "_=_": "index", // for facebook
      "new": "new_page",
      "notes": "index",
      "notes/:tag": "index",
      "archived": "archived",
      "search": "search",
      "calendar": "calendar",
      "0:id/edit": "edit_page"
    };

    this.prototype.panels = {
      'edit': new PageEditPanel(),
      'index': new PageListPanel($("#navigator-index"), 'notes', '<i class="fas fa-file-alt"></i> Notes', '/pages.json'),
      'archived': new PageListPanel($("#navigator-archived"), 'archived', '<i class="fas fa-folder-minus"></i> Archive', '/pages/archived.json'),
      'search': new PageSearchPanel($("#navigator-search"), 'search', ''),
      'calendar': new CalendarPanel($("#navigator-calendar"))
    };
  }

  constructor() {
    super();
    this.body_el = $(document.body);
    this.navigator_el = $("#navigator");
    const win = $(window);
    win.resize(() => this.resize());
    win.on('orientationchange', () => {
      $(document.body).removeClass("desktop phone tablet").addClass(device_type());
      delay(500, () => this.resize());
    });

    this._init_hotkeys();

    if (is_ios()) { // hack for iPhone
      $('input,textarea').blur(() => {
        delay(100, () => this.resize());
      });
    }

    delay(1000, () => this.resize());

    $(window).on('focus', () => {
      if (this.current_panel && this.current_panel.focus) { this.current_panel.focus(); }
    });
  }

  index(tag) {
    return this._select('index', tag);
  }

  archived() {
    return this._select('archived');
  }

  search() {
    return this._select('search');
  }

  calendar() {
    return this._select('calendar');
  }

  new_page() {
    return this._select('edit');
  }

  show_page(page_id) {
    return this._select('edit', '0'+page_id);
  }

  edit_page(page_id) {
    return this._select('edit', '0'+page_id);
  }

  update_hash(action) {
    return Backbone.history.navigate(action, {trigger: false});
  }

  _select(panel_name, option) {
    analytics.pageview(`/app#${panel_name}`);
    this.prev_fragment = this.current_fragment;
    this.current_fragment = Backbone.history.getFragment();
    const panel = this.panels[panel_name];
    const done = () => {
      const defer = panel.activate(option);
      defer.done(() => {
        if (this.current_panel) { this.current_panel.is_active = false; }
        this.current_panel = panel;
        this.current_panel.is_active = true;
        this.resize();
        $("#body-loading").hide();
        $("#app").removeClass("invisible");
      });
      return defer.fail(() => {
        this.current_panel.is_active = false;
        this.current_panel.reactivate();
        this.current_fragment = this.prev_fragment;
        this.prev_fragment = undefined;
        this.update_hash(this.current_fragment);
      });
    };

    if (this.current_panel) {
      this.current_panel.is_active = false;
      const panel_defer = this.current_panel.deactivate();
      panel_defer.done(() => {
        $(":focus").blur();
        return done();
      });
      return panel_defer.fail(() => {
        this.current_panel.is_active = true;
        this.current_fragment = this.prev_fragment;
        this.prev_fragment = undefined;
        this.update_hash(this.current_fragment);
      });
    } else {
      return done();
    }
  }

  _init_hotkeys() {
    const keydown = ev => {
      if (this.current_panel && (!ModalDialog || (ModalDialog.modal_counter === 0))) {
        if (!ev) { ev = event; }
        this.current_panel.hotkeys(ev, String.fromCharCode(ev.keyCode));
      }
    };

    if (document.addEventListener) {
      document.addEventListener("keydown", keydown, false);
    } else if (document.attachEvent) {
      document.attachEvent("onkeydown", keydown);
    } else {
      document.onkeydown = keydown;
    }
  }

  resize() {
    if (device_type() === 'phone') {
      $("#topbar").addClass("dropup");
      $("#topbar>div").removeClass("pull-right");
    } else {
      $("#topbar").removeClass("dropup");
      $("#topbar>div").addClass("pull-right");
    }
    resize_el(this.navigator_el, window_height());
    resize_el(this.body_el, window_height());
    if (this.current_panel && this.current_panel.is_active) { this.current_panel.resize(); }
  }
}
AppRouter.initClass();

$.ajaxSetup({
  timeout: 30 * 1000});

$(document).ready(function() {
  if (device_type() === 'desktop') {
    $(document.body).css('min-width', '1000px');
  }
  $(document.body).addClass(device_type());
  window.router = new AppRouter();
  Backbone.history.start();

  const userAgent = window.navigator.userAgent.toLowerCase();
  if (userAgent.indexOf('android') > 0) {
    new iScroll('list-page-wrapper');
    new iScroll('calendar-list-wrapper');
  }

  if (is_app()) {
    if (window.localStorage['hash']) { Backbone.history.navigate(window.localStorage['hash'], {trigger:true}); }
    Backbone.$(window).on('hashchange', () => window.localStorage['hash'] = Backbone.history.getHash());
  }

  const konami = new Konami();
  konami.code = function() {
    if (localStorage.secret_tags === 'true') {
      $('.secret').css('display', 'none');
      localStorage.secret_tags = 'false';
    } else {
      $('.secret').css('display', 'inline');
      localStorage.secret_tags = 'true';
    }
  };
  konami.load();
  if (localStorage.secret_tags === 'true') {
    $('.secret').css('display', 'inline');
  }
});
