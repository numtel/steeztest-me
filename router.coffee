titleRoot = 'SteezTest.me'

setTitle = (value) ->
  document.title = (if value then value + ' - ' else '') + titleRoot

loggedIn = (loggedOut) ->
  if Meteor.loggingIn() or !CssTestsHandle.ready()
    # Display loading page
    setTitle 'Loading'
    this.render 'loadingPage'
    return false
  else if Meteor.user()
    # Display page as expected in main layout
    this.layout 'loggedInLayout'
    return true
  else if loggedOut
    # Render logged out replacement
    this.render loggedOut
    return false
  else
    # Nothing else, error!
    setTitle 'Error'
    this.render 'error', {data: 'Must be logged in to continue.'}
    return false

homeRoute = () ->
  setTitle()
  if loggedIn.call this, 'welcome'
    this.render 'dashboard'
Router.route '/', homeRoute, {name: 'home'}

testCreateRoute = () ->
  if loggedIn.call this
    setTitle this.route.options.title
    this.render 'modify'
Router.route '/create', testCreateRoute, {
  name: 'test.create',
  title: 'Create New Test'
}

testRoute = (template) ->
  return ->
    if loggedIn.call this
      testCase = CssTests.findOne this.params._id
      if not testCase
        setTitle 'Invalid case specified'
        this.render 'error', {data: 'Invalid case specified.'}
      else
        setTitle _.template this.route.options.title, testCase
        this.render template, {data: {test: testCase}}
Router.route '/case/:_id', testRoute('details'), {
  name: 'test.details',
  title: '<%= title %>'
}
Router.route '/case/:_id/edit', testRoute('modify'), {
  name: 'test.modify',
  title: 'Modifying "<%= title %>"'
}

if Meteor.isClient
  Meteor.startup ()->
    Hooks.init()
  Hooks.onLoggedOut = (userId) ->
    Router.go 'home'
