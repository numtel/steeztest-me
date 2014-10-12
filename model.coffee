@CssTests = new Meteor.Collection 'CssTests'

isInteger = () ->
  if this.value == undefined or /^(-)?[0-9]+$/.test this.value
    return true
  else
    return 'Must be integer.'

CssTests.attachSchema new SimpleSchema {
  title: {
    type: String,
    label: 'Title',
    max: 200
  },
  description: {
    type: String,
    label: 'Description',
    optional: true,
    max: 5000,
    autoform: {rows: 5}
  },
  interval: {
    type: Number,
    label: 'Schedule Interval',
    optional: true,
    min: 1,
    custom: isInteger
  },
  copies: {
    type: Number,
    label: 'Number of copies',
    min: 0
  },
  lastExecution: {
    type: Date,
    label: 'Last date this book was checked out',
    optional: true
  },
  summary: {
    type: String,
    label: 'Brief summary',
    optional: true,
    max: 1000
  }
}

if Meteor.isServer
  Meteor.publish 'myCssTests', () ->
    return CssTests.find {} # {owner: this.userId}

if Meteor.isClient
  Meteor.subscribe 'myCssTests'

