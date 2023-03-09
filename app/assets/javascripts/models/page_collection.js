/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require underscore/underscore
//= require backbone/backbone
//= require shared/defer
//= require shared/localstorage
//= require shared/jscache
//= require session

// shered/jscache (https://github.com/monsur/jscache/blob/master/cache.js)

var cache = new Cache(128 * 1024, false, new Cache.LocalStorageCacheStorage('page-collection'));

class PageCollection {
  constructor(url) {
    _.extend(this, Backbone.Events);
    this.url = url;
    this.clear();
  }

  load(use_cache){
    if (use_cache) {
      const cached_data = cache.getItem(this.url);
      if (cached_data) {
        try {
          this._parse_data(cached_data);
          this.load_from_network().done(data => {
            this.trigger('update');
          });
          const defer = $.Deferred();
          defer.resolve();
          return defer.promise();
        } catch (err) {
          cache.removeItem(this.url);
          return this.load_from_network();
        }
      } else {
        return this.load_from_network();
      }
    } else {
      return this.load_from_network();
    }
  }

  load_from_network() {
    return Deferred(defer => {
      if (this.request) { this.request.abort(); }
      this.request = authorizedRequest({url: this.url, type: 'GET'});
      this.request.done(data => {
        this._parse_data(data);
        cache.setItem(this.url, data);
        this.request = undefined;
        defer.resolve();
      });
      return this.request.fail((xhr, textStatus, errorThrows) => {
        if (!xhr.getAllResponseHeaders()) {
          defer.reject('aborted');
        } else {
          cache.removeItem(this.url);
          defer.reject('error', textStatus, errorThrows);
        }
        this.request = undefined;
      });
    });
  }

  _parse_data(data) {
    this.data = data;
    this.pages = data.pages.map(page_data => new Page(page_data));
    this.index = data.index;
    this.total_pages = data.total_pages;
    this.old_pages_url = data.old_pages_url;
    this.new_pages_url = data.new_pages_url;
  }

  abort() {
    if (this.request) { this.request.abort(); }
    this.request = undefined;
  }

  append(collection) {
    if (collection) {
      this.pages = this.pages.concat(collection.pages);
      this.total_pages = collection.total_pages;
      this.old_pages_url = collection.old_pages_url;
    }
  }

  old_collection() {
    if (this.old_pages_url) {
      return new PageCollection(this.old_pages_url);
    } else {
      return undefined;
    }
  }

  new_collection() {
    if (this.new_pages_url) {
      return new PageCollection(this.new_pages_url);
    } else {
      return undefined;
    }
  }

  clear() {
    this.pages = [];
    this.data = undefined;
    this.index = 0;
    this.total_pages = 0;
    this.old_page_url = undefined;
    this.new_page_url = undefined;
  }
}


window.PageCollection = PageCollection;
