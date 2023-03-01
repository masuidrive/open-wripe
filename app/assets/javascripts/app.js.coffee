#= require jquery/dist/jquery
#= require jquery-ui/dist/jquery-ui
#= require bootstrap2/docs/assets/js/bootstrap
#= require underscore/underscore
#= require backbone/backbone
#= require shared/utils
#= require shared/app_cache
#= require shared/feedback
#= require shared/analytics
#= require iscroll/src/iscroll-lite
#= require konami
#= require_tree ./app

# shared/sprintf.js (https://github.com/azatoth/jquery-sprintf)
# konami.js (https://github.com/georgemandis/konami-js)

class AppRouter extends Backbone.Router
  routes:
    "": "index",
    "_=_": "index", # for facebook
    "new": "new_page",
    "notes": "index",
    "notes/:tag": "index",
    "archived": "archived",
    "search": "search",
    "calendar": "calendar",
    "0:id/edit": "edit_page"

  panels:
    'edit': new PageEditPanel()
    'index': new PageListPanel($("#navigator-index"), 'notes', '<i class="icon-file-alt"></i> Notes', '/pages.json')
    'archived': new PageListPanel($("#navigator-archived"), 'archived', '<i class="icon-folder-close"></i> Archive', '/pages/archived.json')
    'search': new PageSearchPanel($("#navigator-search"), 'search', '')
    'calendar': new CalendarPanel($("#navigator-calendar"))

  constructor: ->
    super()
    @body_el = $(document.body)
    @navigator_el = $("#navigator")
    win = $(window)
    win.resize => @resize()
    win.on 'orientationchange', =>
      $(document.body).removeClass("desktop phone tablet").addClass(device_type())
      delay 500, => @resize()

    @_init_hotkeys()

    if is_ios() # hack for iPhone
      $('input,textarea').blur =>
        delay 100, => @resize()

    delay 1000, => @resize()

    $(window).on 'focus', =>
      @current_panel.focus() if @current_panel && @current_panel.focus

  index: (tag) ->
    @_select 'index', tag

  archived: ->
    @_select 'archived'

  search: ->
    @_select 'search'

  calendar: ->
    @_select 'calendar'

  new_page: ->
    @_select 'edit'

  show_page: (page_id) ->
    @_select 'edit', '0'+page_id
  
  edit_page: (page_id) ->
    @_select 'edit', '0'+page_id

  update_hash: (action) ->
    Backbone.history.navigate(action, {trigger: false})

  _select: (panel_name, option) ->
    analytics.pageview("/app##{panel_name}")
    @prev_fragment = @current_fragment
    @current_fragment = Backbone.history.getFragment()
    panel = @panels[panel_name]
    done = () =>
      defer = panel.activate(option)
      defer.done =>
        @current_panel.is_active = false if @current_panel
        @current_panel = panel
        @current_panel.is_active = true
        @resize()
        $("#body-loading").hide()
        $("#app").removeClass("invisible")
      defer.fail =>
        @current_panel.is_active = false
        @current_panel.reactivate()
        @current_fragment = @prev_fragment
        @prev_fragment = undefined
        @update_hash(@current_fragment)

    if @current_panel
      @current_panel.is_active = false
      panel_defer = @current_panel.deactivate()
      panel_defer.done =>
        $(":focus").blur()
        done()
      panel_defer.fail =>
        @current_panel.is_active = true
        @current_fragment = @prev_fragment
        @prev_fragment = undefined
        @update_hash(@current_fragment)
    else
      done()

  _init_hotkeys: ->
    keydown = (ev) =>
      if @current_panel && (!ModalDialog || ModalDialog.modal_counter == 0)
        ev = event unless ev
        @current_panel.hotkeys(ev, String.fromCharCode(ev.keyCode))
    
    if document.addEventListener
      document.addEventListener("keydown", keydown, false)
    else if document.attachEvent
      document.attachEvent("onkeydown", keydown)
    else
      document.onkeydown = keydown

  resize: ->
    if device_type() == 'phone'
      $("#topbar").addClass("dropup")
      $("#topbar>div").removeClass("pull-right")
    else
      $("#topbar").removeClass("dropup")
      $("#topbar>div").addClass("pull-right")
    resize_el(@navigator_el, window_height())
    resize_el(@body_el, window_height())
    @current_panel.resize() if @current_panel && @current_panel.is_active

$.ajaxSetup
  timeout: 30 * 1000

$(document).ready ->
  if device_type() == 'desktop'
    $(document.body).css('min-width', '1000px')
  $(document.body).addClass(device_type())
  window.router = new AppRouter()
  Backbone.history.start()

  userAgent = window.navigator.userAgent.toLowerCase()
  if userAgent.indexOf('android') > 0
    new iScroll('list-page-wrapper')
    new iScroll('calendar-list-wrapper')

  if is_app()
    Backbone.history.navigate(window.localStorage['hash'], {trigger:true}) if window.localStorage['hash']
    Backbone.$(window).on 'hashchange', ->
      window.localStorage['hash'] = Backbone.history.getHash()

  konami = new Konami()
  konami.code = ->
    if localStorage.secret_tags == 'true'
      $('.secret').css('display', 'none')
      localStorage.secret_tags = 'false'
    else
      $('.secret').css('display', 'inline')
      localStorage.secret_tags = 'true'
  konami.load()
  if localStorage.secret_tags == 'true'
    $('.secret').css('display', 'inline')
