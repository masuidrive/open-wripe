#= require jquery
#= require underscore/underscore

userAgent = window.navigator.userAgent.toLowerCase()
_device_type = 'desktop'
if userAgent.indexOf('ipad') > 0
  _device_type = 'tablet'
else if userAgent.indexOf('iphone') > 0 || userAgent.indexOf('ipod') > 0 
  _device_type = 'phone' 
else if userAgent.indexOf('android') > 0
  _device_type = 'android' 

win = $(window)
device_type = ->
  if _device_type == 'android' || _device_type == 'tablet'
    if win.width() > win.height()
      'tablet'
    else
      'phone'
  else
    _device_type

_is_iphone = userAgent.indexOf('applewebkit') > 0 && userAgent.indexOf('iphone') > 0
is_iphone = ->
  _is_iphone

_is_ios = userAgent.indexOf('applewebkit') > 0 && userAgent.indexOf('mobile') > 0
is_ios = ->
  _is_ios

escape_html = _.escape

delay = (wait, callback) ->
  setTimeout(callback, wait)

is_app = () ->
  !!window.navigator.standalone
  # true # debug

window_height = ->
  if is_iphone() && !is_app()
    window.innerHeight
  else
    (document.documentElement.clientHeight || $(window).height())

today_string = () ->
  today = new Date()
  "#{today.getFullYear()}/#{today.getMonth()+1}/#{today.getDate()}"

resize_el = (el, height, recur) ->
  el.height(height)
  if !recur && (el[0].clientHeight || el.height()) != height
    delay 100, -> resize_el(el, height, true)

$.fn.isVisible = ->
  $.expr.filters.visible(@[0])

$.fn.isTextSelected = ->
  @[0] && @[0].selectionStart != @[0].selectionEnd

$.fn.insertToSelection = (ins)->
  if @[0] && @[0].selectionStart != @[0].selectionEnd
    val = @val()
    sstart = @[0].selectionStart
    send = @[0].selectionEnd
    line_head = (sstart == 0) || (val.substr(sstart-1, 1) == "\n")
    selected = val.substring(sstart, send-1).replace(/\n/g, "\n#{ins}") 
    str = val.substr(0, sstart) + (if line_head then ins else '') + selected + val.substr(send-1)
    @val(str)
    @[0].selectionStart = sstart
    @[0].selectionEnd = sstart + (if line_head then 1 else 0) + selected.length + 1

$.fn.removeToSelection = (ins)->
  if @[0] && @[0].selectionStart != @[0].selectionEnd
    val = @val()
    sstart = @[0].selectionStart
    send = @[0].selectionEnd
    line_head = (val.substr(sstart-1, 1) == "\n") && (val.substr(sstart, ins.length) == ins)
    selected = val.substring(sstart, send-1).replace(new RegExp("\n#{ins}", "g"), "\n")
    selected = selected.substr(ins.length) if line_head
    str = val.substr(0, sstart) + selected + val.substr(send-1)
    @val(str)
    @[0].selectionStart = sstart
    @[0].selectionEnd = sstart + selected.length + 1

window.delay = delay
window.device_type = device_type
window.is_iphone = is_iphone
window.is_ios = is_ios
window.escape_html = escape_html
window.today_string = today_string
window.window_height = window_height
window.resize_el = resize_el
window.is_app = is_app
