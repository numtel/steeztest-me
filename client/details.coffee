Template.detailsHeader.events
  'click .duplicate': (event) ->
    test = this
    test.duplicate (error, _id) ->
      throw error if error
      Router.go 'test.details',
        _id: _id
  'click .delete': (event) ->
    test = this
    bootbox.dialog
      message: 'Are you sure you wish to delete "' + test.title + '?"',
      title: 'Delete Test Case',
      buttons:
        cancel:
          label: 'Cancel',
          className: 'btn-default'
        delete:
          label: 'Yes, delete it.',
          className: 'btn-danger',
          callback: ->
            test.remove()
            Router.go 'home'
