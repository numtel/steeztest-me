phantomExec = phantomLaunch
  debug: true

Meteor.methods
  phantomMethod: (method, options)->
    throw new Meteor.Error 400, 'invalid-method' if not phantomMethods[method]
    return phantomExec phantomMethods[method], options
