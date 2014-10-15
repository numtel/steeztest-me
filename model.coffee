@CssTests = new Meteor.Collection 'CssTests',
  transform: (doc) ->
    return new CssTest doc

CssTests.attachSchema new SimpleSchema
  title:
    type: String,
    label: 'Title',
    max: 200
  description:
    type: String,
    label: 'Description',
    optional: true,
    max: 5000,
    autoform:
      rows: 5
  interval:
    type: Number,
    label: 'Schedule Interval',
    optional: true,
    min: 1
  remoteStyles:
    type: String,
    label: 'Remote Styles',
    optional: true,
    max: 300
  cssFiles:
    type: String,
    label: 'CSS Files',
    max: 1000,
    optional: true,
    autoform:
      rows: 4
  testUrl:
    type: String,
    label: 'Test URL',
    optional: true,
    max: 300
  widths:
    type: String,
    label: 'Test Viewport Widths',
    max: 200,
    defaultValue: '1024',
    regEx: /^[0-9,\s]+$/
  fixtureHtml:
    type: String,
    label: 'Fixture HTML',
    max: 50000,
    autoform:
      rows: 8
  owner:
    type: String,
    label: 'Owner',
    optional: true,
    autoform:
      omit: true
    autoValue: () ->
      return Meteor.userId()
  rank:
    type: Number,
    label: 'Rank',
    optional: true,
    autoform:
      omit: true,
      skipInDuplicate: true
  lastPassed:
    type: Boolean,
    label: 'Passed last time',
    optional: true,
    autoform:
      omit: true,
      skipInDuplicate: true
  hasNormative:
    type: Boolean,
    label: 'Has active normative',
    optional: true,
    autoform:
      omit: true,
      skipInDuplicate: true

@CssHistory = new Meteor.Collection 'CssHistory'

[CssTests, CssHistory].forEach (collection) ->
  if Meteor.isServer
    collection._ensureIndex 'owner'
    Meteor.publish 'my' + collection._name, ->
      return collection.find
        owner: this.userId

    isOwner = (userId, doc) ->
      return userId and doc.owner == userId

    collection.allow
      insert: isOwner
      update: isOwner
      remove: isOwner
      fetch: ['owner']

  if Meteor.isClient
    collection.handle = Meteor.subscribe 'my' + collection._name

