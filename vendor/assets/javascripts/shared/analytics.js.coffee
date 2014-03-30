class Analytics
  collect_url: "https://ssl.google-analytics.com/collect"

  constructor: (@tracking_id) ->
    if @tracking_id
      storage = window.localStorage || {}
      storage.analytics_cid = parseInt((new Date()).getTime()*Math.random()) unless storage.analytics_cid
      @cid = parseInt(storage.analytics_cid)

  pageview: (path) ->
    return unless @tracking_id
    return unless navigator.onLine
    data =
      v: 1 # Version
      t: 'pageview' # Hit type
      tid: @tracking_id
      cid: @cid # anonymous customer ID
      dp: path

    $.ajax
      url: @collect_url
      method: 'POST'
      data: data

  event: (options) ->
    return unless @tracking_id
    return unless navigator.onLine
    data =
      v: 1 # Version
      t: 'event' # Hit type
      tid: @tracking_id
      cid: @cid # anonymous customer ID
    for value, key of options
      data[key] = value

    $.ajax
      url: @collect_url
      method: 'POST'
      data: data

###
https://ssl.google-analytics.com/collect
  ?v=1
  &t=event // Hit type
  &tid=UA-7634164-5 // my profil ID
  &cid=555 // anonymous customer ID
  &dh=myofflinestore.com // my "hostname" =)
  &ec=Motion%20Detector // Event category
  &ea=In // Customer direction: going in or out?
  &ev=1 // Event value
  &cm5=1 // Custom metric (+1 increment)

v=1             // Version.
&tid=UA-XXXX-Y  // Tracking ID / Web property / Property ID.
&cid=555        // Anonymous Client ID.

&t=event        // Event hit type
&ec=video       // Event Category. Required.
&ea=play        // Event Action. Required.
&el=holiday     // Event label.
&ev=300         // Event value.

https://ssl.google-analytics.com/collect?v=1&t=event&tid=UA-40504922-4&cid=555&dh=wri.pe&ec=test
###

if location.host == 'wri.pe'
  window.analytics = new Analytics("UA-40504922-4")
else
  window.analytics = new Analytics()
