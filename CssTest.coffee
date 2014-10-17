@CssTest = (doc) ->
  _.extend this, doc

CssTest.prototype.widthsArray = () ->
  self = this
  return self.widths.split(',').map (width) ->
    return parseInt width.trim(), 10

CssTest.prototype.duplicate = (callback) ->
  self = this
  schema = CssTests.simpleSchema().schema()
  newDoc = {}
  _.each schema, (field, fieldName) ->
    if !field.autoform?.skipInDuplicate
      newDoc[fieldName] = self[fieldName]
  newDoc.title += ' (Copy)'
  CssTests.insert newDoc, callback

CssTest.prototype.remove = (callback) ->
  self = this
  # TODO Meteor.call 'clearDependents', self._id
  CssTests.remove self._id, callback

CssTest.prototype.getHtml = (options, callback) ->
  self = this

  if typeof options == 'function'
    # Allow only a callback to be passed
    callback = options
    options = undefined

  options = _.defaults options || {},
    fixtureHtml: self.fixtureHtml
    # Specify styles with a single viewport width's output from extractStyles
    normativeValue: undefined
    # Specify difference from normativeValue, with report failures
    diff: undefined
    # Passed after callback from phantomJS, result of getSheetsFromUrl
    remoteSheets: undefined

  styleSheets = ''
  if options.normativeValue == undefined
    # Styles are coming normally
    if self.remoteStyles
      if options.remoteSheets
        # Already gone through phantom
        styleSheets += options.remoteSheets
      else
        # Call phantom
        Meteor.call 'phantomMethod', 'getSheetsFromUrl',
          url: self.remoteStyles
          (error, result) ->
            return callback? error if error
            options.remoteSheets = result
            # Do it again
            self.getHtml options, callback
        return
    self.cssFiles?.split('\n').forEach (href) ->
      href = href.trim()
      styleSheets += \
        '<link href="' + href + \
         (if href.indexOf '?' == -1 \
          then '?force-no-cache-' + Date.now() \
          else '') + \
         '" type="text/css" rel="stylesheet" />\n' \
         if href != ''
  else
    # Styles are coming from expectations
    styleSheets  = stylesheetFromNormative options.normativeValue, \
                                           options.diff
  head = [
    '<head>',
    styleSheets,
    (if self.testUrl then '<base href="' + self.testUrl + '">' else ''),
    '<style>',
    '.steez-highlight-failure { outline: 2px solid #ff0 !important; }',
    '</style>',
    '</head>'
  ].join('\n')

  output = options.fixtureHtml

  if !/\<body[^]+\<\/body\>/i.test output
    # Fixture HTML doesn't contain a <body> element
    output = '<body test-ignore>' + output + '</body>'

  if !/\<html[^]+\<\/html\>/i.test output
    # Fixture HTML doesn't contain a <html> element
    output = '<html test-ignore>' + head + output + '</html>'
  else
    # Place <head> before <body>
    bodyPos = output.toLowerCase().indexOf '<body'
    output = output.substr(0, bodyPos) + head + output.substr(bodyPos)

  callback? undefined, output
  # If no remoteStyles, output is synchronous
  return output

CssTest.prototype.extractStyles = (callback) ->
  self = this
  self.getHtml (error, pageHtml) ->
    return callback? error if error
    Meteor.call 'phantomMethod', 'extractStyles',
      html: pageHtml
      url: self.testUrl
      widths: self.widthsArray()
      callback
  undefined

CssTest.prototype.renderThumbnail = (options, callback) ->
  self = this

  if typeof options == 'function'
    # Allow only a callback to be passed
    callback = options
    options = undefined

  options = _.defaults options || {},
    width: 240
    height: 180

  self.getHtml (error, pageHtml) ->
    return callback? error if error
    Meteor.call 'phantomMethod', 'renderThumbnail',
      html: pageHtml
      testWidth: self.widthsArray()[0]
      width: options.width
      height: options.height
      callback
  undefined

CssTest.prototype.setNormative = (callback) ->
  self = this
  self.extractStyles (error, styles) ->
    return callback? error if error
    Meteor.call 'insertNormative', self._id, styles, callback
  undefined

# @param id - _id of normative to load, undefined for newest
CssTest.prototype.loadNormative = (id, callback) ->
  self = this

  if typeof id == 'function'
    # Allow only a callback to be passed
    callback = id
    id = undefined

  Meteor.call 'loadNormative', self._id, id, callback
  undefined

CssTest.prototype.run = (callback) ->
  self = this
  self.loadNormative (error, normative) ->
    return callback? error if error
    throw new Meteor.Error 400, 'normative-required' if error
    self.extractStyles (error, current) ->
      return callback? error if error
      failures = {}
      _.each current, (styles, width) ->
        if normative.value[width] == undefined
          return callback? new Meteor.Error 400, 'normative-mismatch'
        failures[width] = compareStyles normative.value[width], styles

      # Count failures
      totalFailures = 0
      _.each failures, (viewFailures) ->
        totalFailures += viewFailures.length

      report =
        _id: Random.id()
        time: new Date()
        passed: totalFailures == 0
        normative: normative._id
        fixtureHtml: self.fixtureHtml
        owner: self.owner
        testCase: self._id
        failures: failures

      CssHistory.insert report, (error) ->
        return callback? error if error
        testUpdate =
          lastPassed: report.passed
          lastRun: Date.now()
        if self.interval
          testUpdate.nextRun = testUpdate.lastRun + (self.interval * 60000)
        CssTests.update self._id,
          $set: testUpdate
          (error) ->
            return callback? error if error
            callback? undefined, report
  undefined
