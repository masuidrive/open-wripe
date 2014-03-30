###
$ ->
  appCache = window.applicationCache
  if appCache
    upgrade = ->
      if confirm('Could you upgrade to new version now?')
        if appCache.status == app.UPDATEREADY
          appCache.swapCache()
          location.reload()

    $(appCache).bind "updateready", ->
      upgrade()
    
    if appCache.status == app.UPDATEREADY
      upgrade()

    $(window).bind "online", ->
      appCache.update()
###