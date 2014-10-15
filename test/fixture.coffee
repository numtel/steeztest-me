# Create a fixture CssTest and remove it when done
# @param {func} done - pass through tinytest's onComplete callback
# @param {obj} data - Specify data for fixture beyond default
# @param {func} callback(error, fixture, cleanup) - 
#               Perform test on fixture object, call cleanup() when done
@fixtureCssTest = (done, data, callback) ->
  data = _.defaults data || {},
    title: 'Test Test'
    widths: '1024,720'
    fixtureHtml: '<h1>hello</h1>'
  CssTests.insert data, (error, _id) ->
    if error
      callback? error
      return done()
    fixture = CssTests.findOne _id
    if not fixture
      callback? new Meteor.Error 500, 'insert-error'
      return done()
    cleanup = ->
      fixtureId = fixture._id
      # TODO check dependent normatives, history
      fixture.remove (error) ->
        throw error if error
        stillExists = CssTests.findOne fixtureId
        if stillExists
          throw new Meteor.Error 500, 'fixture-not-removed'
        done()
    callback? undefined, fixture, cleanup
