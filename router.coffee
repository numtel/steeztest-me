titleRoot = 'SteezTest.me'

setTitle = (value) ->
  document.title = (if value then value + ' - ' else '') + titleRoot

loggedIn = (loggedOut) ->
  setTitle this.route.options.title
  if Meteor.loggingIn()
    # Display loading page
    this.render 'loggingIn'
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
    this.render 'error', {data: 'invalid-permission'}
    return false

homeRoute = () ->
  if loggedIn.call this, 'welcome'
    this.render 'dashboard'

createTestRoute = () ->
  if loggedIn.call this
    this.render 'modify'

Router.route '/', homeRoute, {name: 'home'}
Router.route '/create', createTestRoute, {
  name: 'test.create',
  title: 'Create New Test'
}

if Meteor.isClient
  Template.modify.tests = () ->
    return CssTests.find {}
  Template.modify.val = () ->
    return JSON.stringify this
  Meteor.startup ()->
    Hooks.init()

  Hooks.onLoggedOut = (userId) ->
    Router.go 'home'
