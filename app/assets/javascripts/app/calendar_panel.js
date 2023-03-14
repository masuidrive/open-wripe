/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
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
//= require messages

class CalendarPanel extends AbsolutePanel {
  static initClass() {
    this.el =
      {generate_key: "#calendar-sync-generate-key"};
  }

  constructor(tab_el) {
    super(CalendarPanel);
    this.tab_el = tab_el;
    this.container_el = $('#calendar-container');
    this.year_el = $('#calendar-year');
    this.month_el = $('#calendar-month');
    this.loading_el = $('#calendar-loading');
    this.loading_error_el = $('#calendar-loading-error');
    this.loading_error_text_el = $('#calendar-loading-error-text');
    this.date_el = $("#calendar-date");
    this.no_items_el = $('#calendar-no-items');
    $('#calendar-prev-month-button').click(() => this.prev_month());
    $('#calendar-next-month-button').click(() => this.next_month());
    $('#calendar-go').click(() => {
      return this.load(this.year_el.val(), this.month_el.val());
    });
    this.generate_key_el.click(() => {
      this.request = authorizedRequest({url: "/calendar/generate_export_key.json", type: 'POST'});
      return this.request.done(data => {
        return load_session();
      });
    });
  }


  activate() {
    return Deferred(defer => {
      this.tab_el.tab('show');
      this.no_items_el.hide();
      const today = new Date();
      this.load(today.getFullYear(), today.getMonth() + 1);
      this.container_el.show();
      return defer.resolve();
    });
  }

  deactivate() {
    return Deferred(defer => {
      this.container_el.hide();
      return defer.resolve();
    });
  }

  load(year, month) {
    this.year_el.val(year);
    this.month_el.val(month);
    if (this.loading_collection) { this.loading_collection.abort(); }
    this.loading_collection = new PageCollection(`/pages/calendar.json?year=${year}&month=${month}`);
    this.loading_collection.on('update', () => {
      this.render();
    });

    this.loading_el.show();
    this.loading_error_el.hide();
    const load_defer = this.loading_collection.load(this.url);
    load_defer.always(() => {
      this.loading_el.hide();
    });
    load_defer.done(() => {
      this.collection = this.loading_collection;
      this.loading_collection = undefined;
      this.render();
    });
    return load_defer.fail(error => {
      this.loading_collection = undefined;
      this.loading_error_text_el.text(error);
      this.loading_error_el.show();
    });
  }

  render() {
    if (this.collection) {
      const {
        data
      } = this.collection;
      this.date_el.html(`${msg.english_months[data.month-1]} ${data.year}`);
      const cal = [];
      this.collection.pages.forEach(page => {
        return page.dates.forEach(date => {
          const day = parseInt(date.split(/[-\/]/)[2]);
          cal[day] = cal[day] || [];
          cal[day].push(page);
        });
      });
      if (this.collection.pages.length === 0) {
        this.no_items_el.show();
      } else {
        this.no_items_el.hide();
      }

      const days = (new Date(data.year, (data.month-1)+1,0)).getDate();
      let wday = (new Date(data.year, (data.month-1),1)).getDay();
      wday = wday === 0 ? 6 : wday - 1; // start monday

      let html = '';
      if (wday > 0) { for (let i = 1; i <= wday; i++) { html += '<li class="day blank"></li>'; } }
      for (let day = 1; day <= days; day++) {
        var w = ` <span class=\"wday\">${msg.wdays[((day - 1) + wday) % 7]}</span>`;
        var yearmonth = `<span class=\"year-month\">${data.year}-${data.month}-</span>`;
        html += `<li class=\"day${cal[day] ? '' : ' blank'}\"><span class=\"wrap\">${yearmonth}${day}${w} <ul>`;
        if (cal[day]) {
          html += cal[day].map(p => {
            return `<li class=\"page\"><a href=\"\#${escape_html(p.key)}/edit\" title=\"${escape_html(p.title)}\">${escape_html(p.title)}</a></li>`;
        }).join('');
        }
        html += '</ul></span></li>';
      }

      $("#calendar-list").html(html);
    }
  }
      //if device_type() == 'desktop'
      //  $("#calendar-list a").tooltip("hide");

  next_month() {
    if (this.collection) {
      const date = new Date(this.collection.data.year, (this.collection.data.month - 1) + 1, 1);
      this.load(date.getFullYear(), date.getMonth() + 1);
    }
  }

  prev_month() {
    if (this.collection) {
      const date = new Date(this.collection.data.year, (this.collection.data.month - 1) - 1, 1);
      this.load(date.getFullYear(), date.getMonth() + 1);
    }
  }

  resize() {
    this.container_el.show();
    this.full_height($("#calendar-pane"), 0);
    this.full_height($("#calendar-sidebar-pane"), 0);
  }

  hotkeys(ev, keychar) {
    switch (keychar) {
      case 'N':
        ev.preventDefault();
        Backbone.history.navigate('new', {trigger: true});
        break;
      case 'I':
        ev.preventDefault();
        Backbone.history.navigate('notes', {trigger: true});
        break;
      case 'A':
        ev.preventDefault();
        Backbone.history.navigate('archived', {trigger: true});
        break;
      case 'S':
        ev.preventDefault();
        Backbone.history.navigate('search', {trigger: true});
        break;
      case 'H':
        ev.preventDefault();
        $('#calendar-prev-month-button').trigger('click');
        break;
      case 'L':
        ev.preventDefault();
        $('#calendar-next-month-button').trigger('click');
        break;
    }

    switch (ev.keyCode) {
      case 37: // left
        ev.preventDefault();
        $('#calendar-prev-month-button').trigger('click');
        break;
      case 39: // right
        ev.preventDefault();
        $('#calendar-next-month-button').trigger('click');
    }
  }
}
CalendarPanel.initClass();

window.CalendarPanel = CalendarPanel;