@CssTest = (doc) ->
  _.extend this, doc

CssTest.prototype.duplicate = (callback) ->
  self = this
  schema = CssTests.simpleSchema().schema()
  newDoc = {}
  _.each schema, (field, fieldName) ->
    if !field.autoform?.skipInDuplicate
      newDoc[fieldName] = self[fieldName]
  newDoc.title += ' (Copy)'
  CssTests.insert newDoc, (error, _id) ->
    callback? error, _id

CssTest.prototype.remove = (callback) ->
  self = this
  #TODO Meteor.call 'clearDependents', self._id
  CssTests.remove self._id, (error) ->
    callback? arguments
