CRUDApi = require './_crud'

class CompanyApi extends CRUDApi

  model: require './../models/company'

###############################################################################
## Data loading (should be removed soon)
###############################################################################

  clear: -> @model.find({}).remove()


module.exports = new CompanyApi()