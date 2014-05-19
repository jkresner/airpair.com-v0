class QueryHelper

  select: (obj, selectList) ->
    if !selectList?
      obj
    else
      _.pickNested obj, _.keys(@view[selectList])


  query:

    active:
      status: $in: ['received','incomplete','waiting','review','scheduling','scheduled','holding','consumed','deferred','pending']


  view:

    # /review by anonymous user
    public:
      '_id': 1
      'company.about': 1
      'company.contacts.pic': 1
      'owner': 1
      'brief': 1
      'availability': 1
      'tags': 1

    # /review by assigned expert
    associated:
      '_id': 1
      'company': 1
      'owner': 1
      'brief': 1
      'availability': 1
      'tags': 1
      'budget': 1
      'pricing': 1
      'suggested': 1

    # /history by customer
    history:
      '_id': 1
      'company.name': 1
      'company.contacts': { $slice: [0, 1] }
      'company.contacts.email': 1
      'company.contacts.fullName': 1
      'company.contacts.pic': 1
      'status': 1
      'owner': 1
      'suggested.expert._id': 1
      'suggested.expert.name': 1
      'suggested.expert.pic': 1
      'calls': 1
      'userId': 1

    # /adm/pipline by admin
    pipeline:
      '_id': 1
      'company.name': 1
      'company.contacts': { $slice: [0, 1] }
      'company.contacts.email': 1
      'company.contacts.fullName': 1
      'company.contacts.pic': 1
      'status': 1
      'owner': 1
      'calls.status': 1
      'suggested.expertStatus': 1
      'suggested.expert.pic': 1
      'tags.short': 1
      'calls.recordings.type': 1
      'userId': 1

module.exports = new QueryHelper()
