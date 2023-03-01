#= require underscore/underscore
#= require backbone/backbone
#= require app/panel
#= require models/page
#= require models/page_collection
#= require shared/defer
#= require shared/labeled_button
#= require shared/relative_date
#= require messages

class CalendarPanel extends AbsolutePanel
  @el:
    generate_key: "#calendar-sync-generate-key"

  constructor: (@tab_el) ->
    super(CalendarPanel)
    @container_el = $('#calendar-container')
    @year_el = $('#calendar-year')
    @month_el = $('#calendar-month')
    @loading_el = $('#calendar-loading')
    @loading_error_el = $('#calendar-loading-error')
    @loading_error_text_el = $('#calendar-loading-error-text')
    @date_el = $("#calendar-date")
    @no_items_el = $('#calendar-no-items')
    $('#calendar-prev-month-button').click => @prev_month()
    $('#calendar-next-month-button').click => @next_month()
    $('#calendar-go').click =>
      @load(@year_el.val(), @month_el.val())
    @generate_key_el.click =>
      @request = authorizedRequest(url: "/calendar/generate_export_key.json", type: 'POST')
      @request.done (data) =>
        load_session();


  activate: ->
    Deferred (defer) =>
      @tab_el.tab('show')
      @no_items_el.hide()
      today = new Date()
      @load(today.getFullYear(), today.getMonth() + 1)
      @container_el.show()
      defer.resolve()

  deactivate: ->
    Deferred (defer) =>
      @container_el.hide()
      defer.resolve()

  load: (year, month) ->
    @year_el.val(year)
    @month_el.val(month)
    @loading_collection.abort() if @loading_collection
    @loading_collection = new PageCollection("/pages/calendar.json?year=#{year}&month=#{month}")
    @loading_collection.on 'update', =>
      @render()

    @loading_el.show()
    @loading_error_el.hide()
    load_defer = @loading_collection.load(@url)
    load_defer.always =>
      @loading_el.hide()
    load_defer.done =>
      @collection = @loading_collection
      @loading_collection = undefined
      @render()
    load_defer.fail (error) =>
      @loading_collection = undefined
      @loading_error_text_el.text(error)
      @loading_error_el.show()

  render: () ->
    if @collection
      data = @collection.data
      @date_el.html("#{msg.english_months[data.month-1]} #{data.year}")
      cal = []
      @collection.pages.forEach (page) =>
        page.dates.forEach (date) =>
          day = parseInt(date.split(/[-\/]/)[2])
          cal[day] = cal[day] || []
          cal[day].push(page)
      if @collection.pages.length == 0
        @no_items_el.show()
      else
        @no_items_el.hide()

      days = (new Date(data.year, (data.month-1)+1,0)).getDate()
      wday = (new Date(data.year, (data.month-1),1)).getDay()
      wday = if wday == 0 then 6 else wday - 1 # start monday

      html = ''
      html += '<li class="day blank"></li>' for i in [1..wday] if wday > 0
      for day in [1..days]
        w = " <span class=\"wday\">#{msg.wdays[(day - 1 + wday) % 7]}</span>"
        yearmonth = "<span class=\"year-month\">#{data.year}-#{data.month}-</span>"
        html += "<li class=\"day#{if cal[day] then '' else ' blank'}\"><span class=\"wrap\">#{yearmonth}#{day}#{w} <ul>"
        if cal[day]
          html += cal[day].map (p) =>
            "<li class=\"page\"><a href=\"\##{escape_html(p.key)}/edit\" title=\"#{escape_html(p.title)}\">#{escape_html(p.title)}</a></li>".join('')
        html += '</ul></span></li>'

      $("#calendar-list").html(html)
      #if device_type() == 'desktop'
      #  $("#calendar-list a").tooltip("hide");

  next_month: ->
    if @collection
      date = new Date(@collection.data.year, (@collection.data.month - 1) + 1, 1)
      @load(date.getFullYear(), date.getMonth() + 1)

  prev_month: ->
    if @collection
      date = new Date(@collection.data.year, (@collection.data.month - 1) - 1, 1)
      @load(date.getFullYear(), date.getMonth() + 1)

  resize: ->
    @container_el.show()
    @full_height($("#calendar-pane"), 0);
    @full_height($("#calendar-sidebar-pane"), 0);

  hotkeys: (ev, keychar) ->
    switch keychar
      when 'N'
        ev.preventDefault()
        Backbone.history.navigate('new', {trigger: true})
      when 'I'
        ev.preventDefault()
        Backbone.history.navigate('notes', {trigger: true})
      when 'A'
        ev.preventDefault()
        Backbone.history.navigate('archived', {trigger: true})
      when 'S'
        ev.preventDefault()
        Backbone.history.navigate('search', {trigger: true})
      when 'H'
        ev.preventDefault()
        $('#calendar-prev-month-button').trigger('click')
      when 'L'
        ev.preventDefault()
        $('#calendar-next-month-button').trigger('click')

    switch ev.keyCode
      when 37 # left
        ev.preventDefault()
        $('#calendar-prev-month-button').trigger('click')
      when 39 # right
        ev.preventDefault()
        $('#calendar-next-month-button').trigger('click')

window.CalendarPanel = CalendarPanel