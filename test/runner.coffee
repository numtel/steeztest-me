# Run tests on this location (client/server), print results to console
# @option {string} pathPrefix - only run specified tests
@runTests = (options) ->
  options = options || {}

  status = {}
  onReport = (report) ->
    key = report.groupPath.join(' - ') + ' - ' + report.test
    if status[key] == undefined
      status[key] = {}
    report.events.forEach (event) ->
      switch event.type
        when 'ok'
          status[key].passed = true
        when 'fail'
          status[key].passed = false
          status[key].details = event.details
        when 'finish'
          status[key].finished = true
          status[key].time = event.timeMs
  onComplete = ->
    countTotal = 0
    countFail = 0
    _.each status, (test, key) ->
      countTotal++
      countFail++ if not test.passed
      console.log \
        (if test.passed then 'PASS' else 'FAIL'), \
        key, \
        '(' + test.time + 'ms)', \
        (if not test.passed then test.details else '')
    if countTotal == 0
      console.log 'No tests found!'
    else if countFail == 0
      console.log 'All tests passed!'
    else
      console.log countFail + ' of ' + countTotal + ' tests failed!'
  Tinytest._runTests onReport, onComplete, options.pathPrefix


