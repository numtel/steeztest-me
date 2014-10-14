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

# Universal helper function
flattenArray = (a) ->
  a = _.map a, _.clone
  b = []
  a.forEach (item) ->
    if item.children?.length
      recursed = flattenArray item.children
      b = b.concat recursed
    item.children = undefined
  return a.concat b

# getHtml helper function
stylesheetFromNormative = (normative, diff) ->
  elements = flattenArray normative
  style = ['<style>']
  elements.forEach (element) ->
    diff?.forEach (diffItem) ->
      if diffItem.selector == element.selector
        diffItem.instances.forEach (instance) ->
          element.attributes[instance.key] = instance.bVal
    rule = element.selector + '{'
    _.each element.attributes, (val, key) ->
      rule += key + ': ' + val + '; '
    rule += '}'
    style.push rule
  style.push '</style>'
  return style.join '\n'

CssTest.prototype.getHtml = (options, callback) ->
  self = this
  options = _.defaults options || {},
    fixtureHtml: self.fixtureHtml
    normativeValue: undefined # For reference
    diff: undefined # For reference

  styleSheets = ''
  # if options.normativeValue == undefined
    # Styles are coming normally
