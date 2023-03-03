/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require app/page_list_panel

class PageSearchPanel extends PageListPanel {
  constructor(tab_el, tab_name) {
    super(tab_el, tab_name, '', '/pages/search.json?q=');
    this.search_box_el = $('#list-page-searchbox');
    this.search_query_el = $('#list-page-search-query');
    this.empty_message_el = $('#list-page-search-empty');
    this.search_box_el.on('submit', e => {
      e.preventDefault();
      this.load();
    });
  }

  activate() {
    this.search_box_el.show();
    delay(100, () => {
      return this.search_query_el.focus();
    });
    return super.activate();
  }

  deactivate() {
    this.search_box_el.hide();
    return super.deactivate();
  }

  load(collection) {
    if (this.search_query_el.val() !== '') {
      if (!collection) { collection = new PageCollection(this.root_url+encodeURI(this.search_query_el.val())); }
      return super.load(collection);
    }
  }
}


window.PageSearchPanel = PageSearchPanel;