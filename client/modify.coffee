AutoForm.hooks {
  modify: {
    onSuccess: (operation, result, template) ->
      Router.go 'test.details', {
        _id: if operation == 'insert' then result else this.docId
      }
  }
}
