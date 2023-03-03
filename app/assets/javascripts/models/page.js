/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require underscore/underscore
//= require backbone/backbone
//= require shared/localstorage
//= require shared/pickup_dates
//= require shared/defer
//= require shared/jscache
//= require session

// shared/jscache (https://github.com/monsur/jscache/blob/master/cache.js)

var cache = new Cache(512 * 1024, false, new Cache.LocalStorageCacheStorage('page'));

class Page {
  constructor(data) {
    _.extend(this, Backbone.Events);
    this.save_status = undefined;
    this.title = `${today_string()} `;
    this.body = '';
    this.archived = false;
    this.saved_data = {
      body: this.body,
      title: this.title,
      archived: this.archived
    };
    if (data) { this.update(data); }
  }

  load(key) {
    const cached_data = cache.getItem(key);
    if (cached_data) {
      try {
        this.update(cached_data.page);
        this.load_from_network(key).done(() => {
          if (cached_data.page.lock_version !== this.lock_version) {
            this.trigger('update', cached_data);
          }
        });
        const defer = $.Deferred();
        defer.resolve();
        return defer.promise();
      } catch (err) {
        cache.removeItem(this.url);
        return this.load_from_network(key);
      }
    } else {
      return this.load_from_network(key);
    }
  }

  check_update() {
    if ((this.key || '') !== '') {
      const original_lock_version = this.lock_version;
      const original_data = this.saved_data;
      return this.load_from_network(this.key).done(() => {
        if (original_lock_version !== this.lock_version) {
          this.trigger('update', {page: original_data});
        }
      });
    }
  }

  load_from_network(key) {
    return Deferred(defer => {
      if (this.request) { this.request.abort(); }
      this.request = authorizedRequest({url: `/${key}.json`, type: 'GET'});
      this.request.done(data => {
        cache.setItem(data.page.key, data);
        this.saved_data = data.page;
        this.update(data.page);
        defer.resolve();
        this.request = undefined;
      });
      return this.request.fail((xhr, textStatus, errorThrows) => {
        if (xhr.status === 401) { // Unauthorized
          sign_out();
        } else if (xhr.status === 404) {
          defer.reject('notfound');
        } else if (!xhr.getAllResponseHeaders()) {
          defer.reject('aborted');
        } else {
          cache.removeItem(key);
          defer.reject('error', textStatus, errorThrows);
        }
        this.request = undefined;
      });
    });
  }

  save() {
    return Deferred(defer => {
      let method, url;
      if (this.key) {
        url = `/${this.key}.json`;
        method = 'PUT';
      } else {
        url = '/pages.json';
        method = 'POST';
      }

      if (this.request) { this.request.abort(); }
      this.request = authorizedRequest({url, method, data: this.http_data()});
      this.request.done(data => {
        cache.setItem(data.page.key, data);
        this.saved_data = data.page;
        this.update(data.page);
        this.request = undefined;
        return defer.resolve();
      });
      return this.request.fail((xhr, textStatus, errorThrows) => {
        this.request = undefined;
        if (xhr.status === 409) { // Conflict
          let data;
          try { 
            data = JSON.parse(xhr.responseText);
          } catch (err) {
            data = undefined;
          }
          return defer.reject('conflict', data);
        } else if (!xhr.getAllResponseHeaders()) {
          return defer.reject('aborted');
        } else {
          cache.removeItem(this.key);
          return defer.reject('error', textStatus, errorThrows);
        }
      });
    });
  }

  destroy() {
    return Deferred(defer => {
      const resolve = () => {
        this.key = (this.saved_data.key = undefined);
        this.title = (this.saved_data.title = ''); 
        this.body = (this.saved_data.body = '');
        this.archived = (this.saved_data.archived = false);
        return defer.resolve();
      };

      cache.removeItem(this.key);
      if (this.key) {
        if (this.request) { this.request.abort(); }
        this.request = authorizedRequest({url: `/${this.key}.json`, type: 'DELETE'});
        this.request.done(data => {
          this.key = undefined;
          this.lock_version = -1;
          this.request = undefined;
          return resolve();
        });
        return this.request.fail((xhr, textStatus, errorThrows) => {
          this.request = undefined;
          if (xhr.status === 401) { // Unauthorized
            return sign_out();
          } else if (!xhr.getAllResponseHeaders()) {
            return defer.reject('aborted');
          } else {
            return defer.reject('error', textStatus, errorThrows);
          }
        });
      } else {
        return resolve();
      }
    });
  }

  is_changed() {
    return (this.key !== this.saved_data.key) || 
    (this.title !== this.saved_data.title) || 
    (this.body !== this.saved_data.body) || 
    (!!this.archived !== !!this.saved_data.archived);
  }

  update(data) {
    this.key = data.key;
    this.title = data.title;
    this.body = data.body;
    this.lock_version = parseInt(data.lock_version);
    this.archived = !!data.archived;
    this.url = data.url;
    this.created_at = parseInt(data.created_at);
    this.modified_at = parseInt(data.modified_at);
    this.user = data.user;
    this.dates = data.dates;
  }

  archive() {
    return authorizedRequest({url: `/${this.key}/archive.json`, type: 'POST'}).done(() => {
      this.archived = true;
    });
  }

  unarchive() {
    return authorizedRequest({url: `/${this.key}/unarchive.json`, type: 'POST'}).done(() => {
      this.archived = false;
    });
  }

  http_data() {
    return {
      page: {
        key: this.key,
        title: this.title,
        body: this.body,
        dates_json: JSON.stringify(pickup_dates(`${this.title} ${this.body}`)),
        lock_version: parseInt(this.lock_version),
        archived: !!this.archived
      }
    };
  }
}

window.Page = Page;
