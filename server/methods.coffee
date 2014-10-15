Future = Npm.require 'fibers/future'

CssNormatives = new Meteor.Collection 'CssNormatives'

phantomExec = phantomLaunch
  debug: true

Meteor.methods
  phantomMethod: (method, options)->
    throw new Meteor.Error 400, 'invalid-method' if not phantomMethods[method]
    return phantomExec phantomMethods[method], options
  insertNormative: (testId, value) ->
    fut = new Future()
    CssNormatives.insert
      testCase: testId
      owner: @userId
      timestamp: Date.now()
      value: value
      (error, _id) ->
        throw error if error
        fut.return _id
    return fut.wait()
  loadNormative: (testId, normativeId) ->
    options =
      sort:
        timestamp: -1
      limit: 1
    query =
      testCase: testId
      owner: @userId
    query._id = normativeId if normativeId

    result = CssNormatives.find(query, options).fetch()
    if result.length > 0
      return result[0]
