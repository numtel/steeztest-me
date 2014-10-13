AutoForm.hooks {
  modify: {
    onSuccess: (operation, result, template) ->
      Router.go 'test.details', {
        _id: if operation == 'insert' then result else this.docId
      }
  }
}

Template.delete.events {
  'click button.btn-danger': (event) ->
    test = @test
    deleteModal = $ '#delete'
    deleteModal.on 'hidden.bs.modal', ->
      test.remove()
      Router.go 'home'
    deleteModal.modal 'hide'
}
