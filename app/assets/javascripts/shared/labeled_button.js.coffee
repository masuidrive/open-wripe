class LabeledButton
  constructor: (@el) ->
  label: (name) ->
    if name
      $('span', @el).hide()
      @name = name
      $("span[name=#{name}]", @el).show()
    else
      @name

  click: (callback) ->
    @el.click callback

  enable: ->
    @el.removeClass('disabled')

  disable: ->
    @el.addClass('disabled')


window.LabeledButton = LabeledButton
