# Only run these tests on the client  
return if Meteor.isServer

Tinytest.addAsync 'CssTest - widthsArray', (test, done) ->
  fixtureAccount done, {}, (error, cleanupAccount) ->
    throw error if error
    fixtureCssTest cleanupAccount, {}, (error, fixture, cleanup) ->
      throw error if error
      test.equal fixture.widthsArray(), [1024, 720]
      cleanup()

Tinytest.addAsync 'CssTest - getHtml', (test, done) ->
  fixtureAccount done, {}, (error, cleanupAccount) ->
    throw error if error
    fixtureCssTest cleanupAccount, {}, (error, fixture, cleanup) ->
      throw error if error
      # ...
      cleanup()
