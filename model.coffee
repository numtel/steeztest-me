@CssTests = new Meteor.Collection 'CssTests', {
  transform: (doc) ->
    return new CssTest doc
}

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
    min: 1
  },
  remoteStyles: {
    type: String,
    label: 'Remote Styles',
    optional: true,
    max: 300
  },
  cssFiles: {
    type: String,
    label: 'CSS Files',
    max: 1000,
    optional: true,
    autoform: {rows: 8}
  },
  testUrl: {
    type: String,
    label: 'Test URL',
    optional: true,
    max: 300
  },
  widths: {
    type: String,
    label: 'Test Viewport Widths',
    max: 200,
    defaultValue: '1024',
    custom: () ->
      if !/^[0-9,\s]+$/.test this.value
        return 'notAllowed'
  },
  fixtureHtml: {
    type: String,
    label: 'Fixture HTML',
    optional: true,
    max: 50000,
    autoform: {rows: 8}
  },
  owner: {
    type: String,
    label: 'Owner',
    optional: true,
    autoform: {omit: true},
    autoValue: () ->
      return Meteor.userId()
  },
  rank: {
    type: Number,
    label: 'Rank',
    optional: true,
    autoform: {
      omit: true,
      skipInDuplicate: true
    }
  },
  lastPassed: {
    type: Boolean,
    label: 'Passed last time',
    optional: true,
    autoform: {
      omit: true,
      skipInDuplicate: true
    }
  },
  hasNormative: {
    type: Boolean,
    label: 'Has active normative',
    optional: true,
    autoform: {
      omit: true,
      skipInDuplicate: true
    }
  }
}

if Meteor.isServer
  CssTests._ensureIndex 'owner'
  Meteor.publish 'myCssTests', ->
    return CssTests.find {owner: this.userId}

  isOwner = (userId, doc) ->
    return userId and doc.owner == userId

  CssTests.allow {
    insert: isOwner
    update: isOwner
    remove: isOwner
  }

if Meteor.isClient
  @CssTestsHandle = Meteor.subscribe 'myCssTests'

