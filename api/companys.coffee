CRUDApi = require './_crud'

class CompanyApi extends CRUDApi

  model: require './../models/company'


module.exports = new CompanyApi()