#= require app/page_list_panel

class PageSearchPanel extends PageListPanel
  constructor: (tab_el, tab_name) ->
    super(tab_el, tab_name, '', '/pages/search.json?q=')
    @search_box_el = $('#list-page-searchbox')
    @search_query_el = $('#list-page-search-query')
    @empty_message_el = $('#list-page-search-empty')
    @search_box_el.on 'submit', (e) =>
      e.preventDefault()
      @load()

  activate: ->
    @search_box_el.show()
    delay 100, =>
      @search_query_el.focus()
    super()

  deactivate: ->
    @search_box_el.hide()
    super()

  load: (collection) ->
    unless @search_query_el.val() == ''
      collection = new PageCollection(@root_url+encodeURI(@search_query_el.val())) unless collection
      super(collection)


window.PageSearchPanel = PageSearchPanel