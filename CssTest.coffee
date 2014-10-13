@CssTest = (doc) ->
  _.extend this, doc

CssTest.prototype.duplicate = ->
  self = this
  schema = CssTests.simpleSchema().schema()
  newDoc = {}
  _.each schema, (field, fieldName) ->
    if !field.autoform?.skipInDuplicate or fieldName == '_id'
      newDoc[fieldName] = self[fieldName]
  newDoc.title += ' (Copy)'
  CssTests.insert newDoc, (error, _id) ->
    throw error if error
    Router.go 'test.details', {_id: _id}

CssTest.prototype.remove = ->
  self = this
  #TODO Meteor.call 'clearDependents', self._id
  CssTests.remove self._id
