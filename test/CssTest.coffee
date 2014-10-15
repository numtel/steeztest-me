  
Tinytest.addAsync 'CssTest - Sample', (test, done) ->
  fixtureCssTest done, {}, (error, fixture, cleanup) ->
    throw error if error
    console.log fixture
    test.equal fixture.title, 'Test Test'
    cleanup()
