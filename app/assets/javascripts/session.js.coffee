#= require'splash'
class EnableAutoSaveDialog extends ModalDialog
  el: $('#edit-page-enable-autosave')


session_data = undefined

get_session = (callback) ->
  res = $.ajax
    url: '/session.json'
    data: {version: $("#wripe-version").text()}
    dataType: 'json'

  res.done (data) ->
    localStorage.session = JSON.stringify(data)
    session_data = data

    # nav
    $('#nav-username').text(data.user.username)
    if navigator.onLine
      $('#nav-usericon').attr('src', data.user.icon_url)

    # csrf
    $("meta[name='csrf-param']").attr('content', data.csrf_param)
    $("meta[name='csrf-token']").attr('content', data.csrf_token)
    $("input[name='#{data.csrf_param}']").val(data.csrf_token)

    if session_data.show_updates
      (new SplashDialog()).show()

    if typeof(session_data.properties.autosave) == 'undefined' || session_data.properties.autosave == null
      dialog = (new EnableAutoSaveDialog).show()
      dialog.done (action) =>
        session.autosave(true)
      dialog.fail (action) =>
        session.autosave(false)
    else
      session.autosave(session_data.properties.autosave, true)
    callback(data)

  res.fail(check_auth)


class Session
  constructor: ->
    _.extend @, Backbone.Events

  autosave: (autosave, advertise=false) ->
    if typeof(autosave) == 'undefined'
      session_data.properties.autosave
    else if advertise
      session_data.properties.autosave = autosave
      @trigger('update_autosave', autosave)
      autosave
    else
      if session_data.properties.autosave != autosave
        session_data.properties.autosave = autosave
        window.authorizedRequest
          method: 'PUT'
          url: '/settings.json'
          data: { autosave: autosave }
        @trigger('update_autosave', autosave)
      autosave

  username: ->
    session_data.user.username

window.session = new Session()

window.authorizedRequest = (options, defer) ->
  defer = jQuery.Deferred() unless defer
  options.beforeSend = (xhr) ->
    if session_data
      xhr.setRequestHeader('X-CSRF-Token', session_data.csrf_token)

  xhr = $.ajax(options)
  xhr.done (data) ->
    defer.resolve(data)

  xhr.fail (xhr, textStatus, errorThrows) ->
    if xhr.status == 412 # CSRF and retry
      get_session () =>
        authorizedRequest(@, defer)

    else if(xhr.status == 401) # Unauthorized
      sign_out()
    
    else 
      defer.reject(xhr, textStatus, errorThrows)

  promise = defer.promise()
  promise.abort = () ->
    xhr.abort()

  promise


show_helps = (helps, pages_count) ->
  $('.alert-help').hide()

  helps.forEach (help) ->
    $(".help-#{help.key}").show()
    close_btn_el = $(".help-#{help.key} a.close")
    close_btn_el.attr('name', help.key)
    close_btn_el.click (e) ->
      authorizedRequest(url: "/helps/#{$(e.target).attr('name')}.json", method: 'DELETE')

  if typeof pages_count != 'undefined'
    if pages_count == 0
      $(".help-welcome").show()
    else
      $(".help-welcome").hide()

  if session_data && session_data.properties && session_data.properties['export-key']
    path = "/calendar/exports/#{session_data.properties['export-key']}.ics"
    url = "http://wri.pe#{path}"
    ssl_url = "https://wri.pe#{path}"
    $("#calendar-sync-external-url-ssl").val(ssl_url)
    $("#calendar-sync-external-url").val(url)
    $("#calendar-sync-gcal").attr('href', "http://www.google.com/calendar/render?cid=#{escape("#{url}?app=gcal")}")


window.local_session = (callback) ->
  if localStorage.session
    try
      sess = JSON.parse(localStorage.session)
      callback(sess)
    catch e
      callback(undefined)
  else
    get_session (data) ->
      callback(data)


window.load_session = () ->
  get_session (data) ->
    show_helps(data.helps, data.pages_count)


$ ->
  if localStorage.session
    try
      data = JSON.parse(localStorage.session)
      $('#nav-username').text(data.user.username)
      show_helps(data.helps, data.pages_count)
    catch e
      # no-op

  load_session()

  $(".help-show-all").click () ->
    authorizedRequest({url: "/helps/reset", method: 'POST'}).done (data) ->
      show_helps(data)


window.sign_out = () ->
  localStorage.clear()
  sessionStorage.clear()
  location.href = '/'


window.check_auth = (xhr, textStatus, errorThrows) ->
  if xhr.status == 412 # CSRF
    getSession =>
      $.ajax(@)
  if xhr.status == 401 # Unauthorized
    sign_out()
