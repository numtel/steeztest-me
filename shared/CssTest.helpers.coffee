
# Universal helper function
@flattenArray = (a) ->
  a = _.map a, _.clone
  b = []
  a.forEach (item) ->
    if item.children?.length
      recursed = flattenArray item.children
      b = b.concat recursed
    item.children = undefined
  return a.concat b

# getHtml helper function
@stylesheetFromNormative = (normative, diff) ->
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

# run helper function
@compareStyles = (a, b) ->
  # specify regexes to filter css attributes by name
  filterRules = []

  # Do this without recursion
  a=flattenArray a
  b=flattenArray b

  if a.length != b.length
    throw new Meteor.Error 400, 'fixture-changed'

  failures = []
  for i in [0...a.length]
    if !a[i].ignore
      _.each a[i].attributes, (aVal, key) ->
        # Check key against filterRules
        skip = false
        filterRules.forEach (rule) ->
          skip = true if rule.test(key)
        return if skip

        bVal = b[i].attributes[key]
        if bVal != aVal
          failures.push
            selector: a[i].selector
            key: key
            aVal: aVal
            bVal: bVal
            aRules: a[i].rules
            bRules: b[i].rules
  return failures
