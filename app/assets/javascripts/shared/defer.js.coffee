window.Deferred = (callback) ->
  defer = $.Deferred()
  if callback
    #try 
      callback(defer)
    #catch error
    #  if console && console.log
    #    console.log(error, error.message)
    #    defer.reject('fatal', error)
    #  defer.promise()
  defer
