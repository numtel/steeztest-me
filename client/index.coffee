Template.list.cases = ->
  return CssTests.find {}, {
    fields: {title: 1, lastPassed: 1, hasNormative: 1}
    sort: {rank: 1}
  }

Template.list.empty = ->
  return Template.list.cases().count() == 0

Template.list.active = ->
  curRoute = Router.current()
  curRouteName = curRoute.route.getName()
  if ['test.details', 'test.modify'].indexOf(curRouteName) > -1
    return curRoute.params._id == @_id if curRoute
  else if curRouteName == 'test.create' and not this._id
    return true

Template.list.rendered = ->
  @$('ul.nav').sortable {
    handle: 'a',
    stop: (event, ui) ->
      ui.item.parent().children().each (i) ->
        item = $(this)
        id = item.children('a').attr('data-id')
        CssTests.update(id, {$set: {rank: i}})
  }
