//= require shared/underscore
//= require shared/backbone
//= require shared/localstorage
//= require shared/pickup_dates
//= require shared/defer
//= require shared/jscache
//= require session


cache = new Cache(512 * 1024, false, new Cache.LocalStorageCacheStorage('page'))

class Page
  constructor: (data) ->
    _.extend @, Backbone.Events
    @save_status = undefined
    @title = "#{today_string()} "
    @tag_list = ''
    @body = ''
    @archived = false
    @saved_data = {
      body: @body,
      title: @title,
      tag_list: @tag_list,
      archived: @archived
    }
    @update(data) if data

  load: (key) ->
    cached_data = cache.getItem(key)
    if cached_data
      try
        @update(cached_data.page)
        @load_from_network(key).done =>
          if cached_data.page.lock_version != @lock_version
            @trigger('update', cached_data)
        defer = $.Deferred()
        defer.resolve()
        defer.promise()
      catch err
        cache.removeItem(@url)
        @load_from_network(key)
    else
      @load_from_network(key)

  check_update: ->
    if (@key || '') != ''
      original_lock_version = @lock_version
      original_data = @saved_data
      @load_from_network(@key).done =>
        if original_lock_version != @lock_version
          @trigger('update', page: original_data)

  load_from_network: (key) ->
    Deferred (defer) =>
      @request.abort() if @request
      @request = authorizedRequest(url: "/#{key}.json", type: 'GET')
      @request.done (data) =>
        cache.setItem(data.page.key, data)
        @saved_data = data.page
        @update(data.page)
        defer.resolve()
        @request = undefined
      @request.fail (xhr, textStatus, errorThrows) =>
        if xhr.status == 401 # Unauthorized
          sign_out()
        else if xhr.status == 404
          defer.reject('notfound')
        else if !xhr.getAllResponseHeaders()
          defer.reject('aborted')
        else
          cache.removeItem(key)
          defer.reject('error', textStatus, errorThrows)
        @request = undefined

  save: ->
    Deferred (defer) =>
      if @key
        url = "/#{@key}.json"
        method = 'PUT'
      else
        url = '/pages.json'
        method = 'POST'

      @request.abort() if @request
      @request = authorizedRequest(url: url, method: method, data: @http_data())
      @request.done (data) =>
        cache.setItem(data.page.key, data)
        @saved_data = data.page
        @update(data.page)
        @request = undefined
        defer.resolve()
      @request.fail (xhr, textStatus, errorThrows) =>
        @request = undefined
        if xhr.status == 409 # Conflict
          try 
            data = JSON.parse(xhr.responseText);
          catch err
            data = undefined
          defer.reject('conflict', data);
        else if !xhr.getAllResponseHeaders()
          defer.reject('aborted')
        else
          cache.removeItem(@key)
          defer.reject('error', textStatus, errorThrows)

  destroy: ->
    Deferred (defer) =>
      resolve = =>
        @key = @saved_data.key = undefined
        @title = @saved_data.title = ''
        @tag_list = @saved_data.tag_list = ''
        @body = @saved_data.body = ''
        @archived = @saved_data.archived = false
        defer.resolve()

      cache.removeItem(@key)
      if @key
        @request.abort() if @request
        @request = authorizedRequest(url: "/#{@key}.json", type: 'DELETE')
        @request.done (data) =>
          @key = undefined
          @lock_version = -1
          @request = undefined
          resolve()
        @request.fail (xhr, textStatus, errorThrows) =>
          @request = undefined
          if xhr.status == 401 # Unauthorized
            sign_out()
          else if !xhr.getAllResponseHeaders()
            defer.reject('aborted')
          else
            defer.reject('error', textStatus, errorThrows)
      else
        resolve()

  is_changed: () ->
    @key != @saved_data.key || 
    @title != @saved_data.title ||
    @tag_list != @saved_data.tag_list ||
    @body != @saved_data.body || 
    !!@archived != !!@saved_data.archived

  update: (data) ->
    @key = data.key
    @title = data.title
    @tag_list = data.tag_list
    @body = data.body
    @lock_version = parseInt(data.lock_version)
    @archived = !!data.archived
    @url = data.url
    @created_at = parseInt(data.created_at)
    @modified_at = parseInt(data.modified_at)
    @user = data.user
    @dates = data.dates

  archive: ->
    authorizedRequest(url: "/#{@key}/archive.json", type: 'POST').done =>
      @archived = true

  unarchive: ->
    authorizedRequest(url: "/#{@key}/unarchive.json", type: 'POST').done =>
      @archived = false

  http_data: ->
    {
      page: {
        key: @key,
        title: @title,
        tag_list: @tag_list
        body: @body,
        dates_json: JSON.stringify(pickup_dates("#{@title} #{@body}"))
        lock_version: parseInt(@lock_version),
        archived: !!@archived
      }
    }

window.Page = Page
