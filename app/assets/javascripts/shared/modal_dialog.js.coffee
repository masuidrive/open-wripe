#= require shared/underscore
#= require shared/backbone


class ModalDialog
  constructor: (options) ->
    _.extend @, Backbone.Events
    options = { show: false } unless options
    @el.unbind 'show'
    @el.on 'show', =>
      ModalDialog.modal_counter += 1
      @shown()
    @el.unbind 'hide'
    @el.on 'hide', (e) =>
      ModalDialog.modal_counter -= 1
      @hidden()
      if @defer
        @defer.reject()
        @defer = undefined

    actions = $("*[data-action]", @el)
    actions.unbind('click')
    actions.click (ev) =>
      ev.preventDefault()
      if @defer
        action_name = $(ev.currentTarget).attr('data-action')
        @action(action_name)
        @defer.resolve(action_name)
        @defer = undefined
        @hide()

    @el.modal(options)

  @modal_counter: 0

  @is_active: ->
    @modal_counter > 0

  show: ->
    Deferred (@defer) =>
      @will_show()
      @el.modal('show')

  hide: ->
    @will_hide()
    @el.modal('hide')

  action: (name) ->
    # please override

  will_show: ->
    # please override

  shown: ->
    # please override

  will_hide: ->
    # please override

  hidden: ->
    # please override


window.ModalDialog = ModalDialog
