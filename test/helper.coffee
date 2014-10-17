# For each in array `trials`, call `func`, finally call `onComplete`
# func(data, done), call done() when complete
@multipleTestData = (trials, onComplete, func) ->
  context = this
  returnCount = 0
  done = ->
    returnCount++
    if returnCount == trials.length
      onComplete()
    else
      func.call context, trials[returnCount], done
  func.call context, trials[returnCount], done
