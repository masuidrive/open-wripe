#= require shared/underscore
#= require shared/backbone
#= require shared/defer
#= require shared/bootstrap

class AbsolutePanel
  constructor: (klass) ->
    _.extend @, Backbone.Events
    @compiled_template = {}

    if klass && klass.el
      for name, selector of klass.el
        @["#{name}_el"] = $(selector)

  activate: ->
    Deferred (defer) =>
      defer.resolve()

  deactivate: ->
    Deferred (defer) =>
      defer.resolve()

  reactivate: ->
    @activate()

  resize: ->

  hotkeys: (ev) ->

  # protected
  template: (name, obj) ->
    unless @compiled_template[name]
      @compiled_template[name] = _.template($("#"+name).html())
    @compiled_template[name](obj)

  full_height: (el, bottom, height_el, recur) ->
    height_el = el unless height_el
    offset = height_el.offset()
    h = (window_height() - offset.top - (bottom || 0))
    el.height(h)
    unless recur
      delay 100, =>
        if el.height() != h
          @full_height(el, bottom, height_el, true)

_.templateSettings = {
  evaluate  : /{%([\s\S]+?)%}/g,
  interpolate : /\${raw ([\s\S]+?)}/g,
  escape    : /\${([\s\S]+?)}/g
};

window.AbsolutePanel = AbsolutePanel
