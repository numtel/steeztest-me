Router.route '/', () ->
  if Meteor.user()
    this.layout 'loggedInLayout'
    this.render 'dashboard'
  else
    this.render 'welcome'

