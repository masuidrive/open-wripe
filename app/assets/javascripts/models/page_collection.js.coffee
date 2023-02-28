#= require shared/underscore
#= require shared/backbone
#= require shared/defer
#= require shared/localstorage
#= require shared/jscache
#= require session

cache = new Cache(128 * 1024, false, new Cache.LocalStorageCacheStorage('page-collection'))

class PageCollection extends Backbone.Events
  constructor: (url) ->
    _.extend @, Backbone.Events
    @url = url
    @clear()

  load: (use_cache)->
    if use_cache
      cached_data = cache.getItem(@url)
      if cached_data
        try
          @_parse_data(cached_data)
          @load_from_network().done (data) =>
            @trigger('update')
          defer = $.Deferred()
          defer.resolve()
          defer.promise()
        catch err
          cache.removeItem(@url)
          @load_from_network()
      else
        @load_from_network()
    else
      @load_from_network()

  load_from_network: ->
    Deferred (defer) =>
      @request.abort() if @request
      @request = authorizedRequest(url: @url, type: 'GET')
      @request.done (data) =>
        @_parse_data(data)
        cache.setItem(@url, data)
        @request = undefined
        defer.resolve()
      @request.fail (xhr, textStatus, errorThrows) =>
        if !xhr.getAllResponseHeaders()
          defer.reject('aborted')
        else
          cache.removeItem(@url)
          defer.reject('error', textStatus, errorThrows)
        @request = undefined

  _parse_data: (data) ->
    @data = data
    @pages = data.pages.map (page_data) -> new Page(page_data);
    @index = data.index
    @total_pages = data.total_pages
    @old_pages_url = data.old_pages_url
    @new_pages_url = data.new_pages_url

  abort: ->
    @request.abort() if @request
    @request = undefined

  append: (collection) ->
    if collection
      @pages = @pages.concat collection.pages
      @total_pages = collection.total_pages
      @old_pages_url = collection.old_pages_url

  old_collection: ->
    if @old_pages_url
      new PageCollection(@old_pages_url)
    else
      undefined

  new_collection: ->
    if @new_pages_url
      new PageCollection(@new_pages_url)
    else
      undefined

  clear: ->
    @pages = []
    @data = undefined
    @index = 0
    @total_pages = 0
    @old_page_url = undefined
    @new_page_url = undefined


window.PageCollection = PageCollection
