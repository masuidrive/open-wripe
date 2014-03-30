#= require shared/underscore
#= require shared/backbone
#= require app/panel
#= require models/page
#= require models/page_collection
#= require shared/defer
#= require shared/labeled_button
#= require shared/relative_date
# require shared/iscroll

class PageListPanel extends AbsolutePanel
  @el:
    'header_title': '#list-page-header-title'
    'welcome': "#help-welcome"
    'auto_loading': "#list-page-auto-loading"

  constructor: (@tab_el, @tab_name, @title, @root_url) ->
    super(PageListPanel)
    @container_el = $('#list-page-container')
    @list_el = $('#list-page')
    @pageno_el = $('#list-page-pageno')
    @loading_el = $('#list-page-loading')
    @loading_error_el = $('#list-page-loading-error')
    @loading_error_text_el = $('#list-page-loading-error-text')
    @empty_message_el = $('#list-page-empty')
    @sidebar_el = $('#list-page-sidebar-pane')
    @list_wrapper_el = $('#list-page-wrapper')

    @loading_collection = undefined
    @collection = undefined

    # monitor position for auto load
    setInterval =>
      if @is_active
        if $("#list-page-auto-loading").offset().top < window_height() * 2
          @load_old_page()
    , 100

    if @tab_name == 'notes'
      request = authorizedRequest(url: "/pages/tags.json", type: 'GET')
      request.done (data) =>
        html = ''
        for tag in data
          html += "<a href=\"#notes/#{encodeURIComponent(tag.name)}\">#{escape_html(tag.name)}</a> "
        $("#list-page-sidebar-tags .body").html(html)

  activate: (@tag) ->
    Deferred (defer) =>
      @tab_el.tab('show')
      @welcome_el.hide()
      
      title = if @tag then "#{@title} / #{@tag}" else @title
      @header_title_el.html(title)
      @cursor = 0
      @container_el.addClass("list-page-#{@tab_name}")
      @container_el.show()
      @clear()
      @list_wrapper_el.scrollTop(0)

      url = @root_url
      if @tag
        url += if @tag.indexOf('?') > -1 then '&' else '?'
        url += "tag=#{encodeURIComponent(@tag)}"

      load_defer = @load(new PageCollection(url))

      if @tab_name == 'notes'
        local_session (data) =>
          load_defer.done =>
            if data.pages_count == 0 && @collection.pages.length == 0
              @welcome_el.show()
      defer.resolve()

  deactivate: ->
    Deferred (defer) =>
      @loading_collection.abort() if @loading_collection
      @collection.abort() if @collection
      @welcome_el.hide()
      @container_el.hide()
      @container_el.removeClass("list-page-#{@tab_name}")
      @empty_message_el.hide()
      defer.resolve()

  clear: ->
    @collection = undefined
    @pageno_el.html('')
    @list_el.html('')
    @loading_error_el.hide()
    @loading_el.hide()
    @empty_message_el.hide()

  render: ->
    @empty_message_el.hide()
    @loading_error_el.hide()
    @loading_el.hide()
    @auto_loading_el.hide()
    @list_el.html('')
    if @collection
      if @collection.pages.length > 0
        @pageno_el.text("#{@collection.total_pages} #{if @collection.total_pages > 1 then 'pages' else 'page'}")
        for i in [0..@collection.pages.length-1]
          page = $.extend({}, @collection.pages[i])
          page.cursor = (@cursor == i)
          @list_el.append(@template('list-page-template', page))
          $("#list-page-archive-"+page.key).click (e) =>
            e.preventDefault()
            @archive($(e.currentTarget).attr('key'))
          $("#list-page-unarchive-"+page.key).click (e) =>
            e.preventDefault()
            @unarchive($(e.currentTarget).attr('key'))
      else
        @empty_message_el.show() if @tab_name == 'archived'

  archive: (page_key) ->
    $("#list-page-moving-#{page_key}").show()
    $("#list-page-archive-#{page_key}").hide()
    $("#list-page-unarchive-#{page_key}").hide()
    page = @page_by_key(page_key)
    defer = page.archive()
    defer.always =>
      $("#list-page-moving-#{page_key}").hide()
    defer.done =>
      $("#list-page-unarchive-#{page_key}").show()
      $.bootstrapGrowl("Archived", {type: 'success', delay:2000});

  unarchive: (page_key) ->
    $("#list-page-moving-#{page_key}").show()
    $("#list-page-archive-#{page_key}").hide()
    $("#list-page-unarchive-#{page_key}").hide()
    page = @page_by_key(page_key)
    defer = page.unarchive()
    defer.always =>
      $("#list-page-moving-#{page_key}").hide()
    defer.done =>
      $("#list-page-archive-#{page_key}").show()
      $.bootstrapGrowl("Move to Notes", {type: 'success', delay:2000});

  load: (collection) ->
    @loading_el.show()
    @loading_error_el.hide()
    @loading_collection.abort() if @loading_collection
    @loading_collection = collection
    @loading_collection.on 'update', =>
      @render()
    load_defer = @loading_collection.load(true)
    load_defer.always =>
      @loading_el.hide()
      @empty_message_el.hide()
    load_defer.done =>
      @collection = @loading_collection
      @loading_collection = undefined
      @render()
    load_defer.fail (error) =>
      @loading_collection = undefined
      @loading_error_text_el.text(error)
      @loading_error_el.show()
    load_defer

  load_old_page: ->
    return if @old_collection || !@collection
    @old_collection = @collection.old_collection()
    if @old_collection
      @auto_loading_el.show()
      load_defer = @old_collection.load()
      load_defer.done =>
        @collection.append(@old_collection)
        @render()
      load_defer.fail (error) =>
        @loading_error_text_el.text(error)
        @loading_error_el.show()
        setTimeout =>
          @load_old_page
        , 3 * 1000
      load_defer.always =>
        @old_collection = undefined
        @auto_loading_el.hide()

  page_by_key: (page_key) ->
    for page in @collection.pages
      return page if page.key == page_key
    undefined

  cursor_move: (idx) ->
    @cursor = idx unless typeof idx == 'undefined'
    $("#list-page>.page").removeClass('cursor')
    $("#list-page .page:nth-child(#{@cursor+1})").addClass('cursor')
    cur = $("#list-page .cursor")
    bottom = 32
    if cur.length > 0 && cur.offset().top < $("#list-page-wrapper").offset().top
      $("#list-page-wrapper").scrollTop($("#list-page").offset().top * -1 + cur.offset().top)
    else if cur.length > 0 && cur.offset().top + cur.height() + bottom > $("#list-page-wrapper").offset().top + $("#list-page-wrapper").height()
      top = -1*$("#list-page").offset().top+cur.offset().top+$("#list-page-wrapper").offset().top-$("#list-page-wrapper").height()
      $("#list-page-wrapper").scrollTop(top + bottom)

  cursor_enter: ->
    unless typeof @cursor == 'undefined'
      href = $("#list-page .page:nth-child(#{@cursor+1}) .title a").attr('href')
      Backbone.history.navigate(href, {trigger:true}) 

  cursor_archive: ->
    unless typeof @cursor == 'undefined'
      page_key = $("#list-page .page:nth-child(#{@cursor+1})").attr('name')
      page = @page_by_key(page_key)
      if page.archived
        @unarchive(page_key)
      else
        @archive(page_key)
      
  cursor_up: ->
    @cursor_move(@cursor - 1) if @cursor > 0

  cursor_down: ->
    @cursor_move(@cursor + 1) if @cursor < @collection.pages.length - 1
  
  resize: ->
    @container_el.show()
    @full_height(@container_el, 0);
    @full_height(@list_wrapper_el, 0);
    @full_height(@sidebar_el, 0);

  hotkeys: (ev, keychar) ->
    key_func = =>
      switch keychar
        when 'E'
          ev.preventDefault()
          @cursor_archive()
        when 'N'
          ev.preventDefault()
          Backbone.history.navigate('new', {trigger: true})
        when 'I'
          ev.preventDefault()
          Backbone.history.navigate('notes', {trigger: true})
        when 'D'
          ev.preventDefault()
          Backbone.history.navigate('archived', {trigger: true})
        when 'C'
          ev.preventDefault()
          Backbone.history.navigate('calendar', {trigger: true})
        when 'S'
          ev.preventDefault()
          Backbone.history.navigate('search', {trigger: true})
        when 'J'
            ev.preventDefault()
            @cursor_down()
        when 'K'
            ev.preventDefault()
            @cursor_up()
        when 'O'
            ev.preventDefault()
            @cursor_enter()

    el = (document.activeElement.tagName || '').toUpperCase()
    if el != 'INPUT' && el != 'TEXTAREA'
      key_func()
      switch ev.keyCode
        when 38 # up
          ev.preventDefault()
          @cursor_up()
        when 40 # down
          ev.preventDefault()
          @cursor_down()
        when 13 # enter
          ev.preventDefault()
          @cursor_enter()
    else if ev.ctrlKey || ev.metaKey || ev.altKey
      key_func()

window.PageListPanel = PageListPanel
