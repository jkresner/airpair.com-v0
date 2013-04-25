
## ? not used
class DataListView extends BB.BadassView
  events:
    'click .edit': (e) -> @formView.render @getModelFromDataId(e)
    'click .delete': 'destroyRemoveModel'
    'click .detail': (e) -> false
  getModelFromDataId: (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data('id')
    _.find @collection.models, (m) -> m.id is id
  destroyRemoveModel: (e) ->
    m = @getModelFromDataId(e)
    m.destroy()
    @collection.remove m