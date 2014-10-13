Template.list.cases = () ->
  return CssTests.find {}, {
    fields: {title: 1, lastPassed: 1, hasNormative: 1}
    sort: {rank: 1}
  }

Template.list.active = () ->
  curRoute = Router.current()
  return curRoute.params._id == @_id if curRoute

Template.list.rendered = () ->
  @$('ul.nav').sortable {
    handle: 'a',
    stop: (event, ui) ->
      ui.item.parent().children().each (i) ->
        item = $(this)
        id = item.children('a').attr('data-id')
        CssTests.update(id, {$set: {rank: i}})
  }
