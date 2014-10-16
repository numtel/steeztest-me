  
if Meteor.isClient
  Tinytest.addAsync 'CssTest - Sample', (test, done) ->
    fixtureAccount done, {}, (error, cleanupAccount) ->
      throw error if error
      fixtureCssTest cleanupAccount, {}, (error, fixture, cleanup) ->
        throw error if error
        test.equal fixture.title, 'Test Test'
        cleanup()
