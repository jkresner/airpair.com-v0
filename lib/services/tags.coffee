request = require 'superagent'
DomainService   = require './_svc'


module.exports = class TagsService extends DomainService

  model: require './../models/tag'
  cmsModel: require './../models/tagCms'

  search: (searchTerm, callback) ->
    # Poor implementation of search, should checkout mongo-text-search or elastic-search
    @model.findOne { $or: [ { soId: searchTerm }, { ghId: searchTerm } ] }, callback

  cms: (id, callback) ->
    @cmsModel.findOne { _id: id }, callback


  create: (addMode, tag, callback) ->
    #console.log 'create', 'addMode', addMode
    if addMode is 'stackoverflow' then @getStackoverflowTag(tag, callback)
    else if addMode is 'github' then @getGithubRepo(tag, callback)
    else @model( tag ).save callback

  getStackoverflowTag: (tag, callback) =>
    encoded = encodeURIComponent tag.nameStackoverflow

    request
      .get("http://api.stackexchange.com/tags/#{encoded}/wikis?site=stackoverflow")
      .end (sres) =>

        error = { e: { message: "tag #{tag.nameStackoverflow} not found" } }
        if not sres.ok then return callback error

        d = sres.body.items[0]

        if not d? then return callback error

        update =
          name: d.tag_name
          short: d.tag_name
          soId: d.tag_name
          desc: d.excerpt
        return @model.findOneAndUpdate soId: d.tag_name, update, { upsert: true }, callback


  getGithubRepo: (tag, callback) =>
    throw new Error 'gittag not implemented'
    # request
    #   .get("https://api.github.com/repos/#{req.body.nameGithub}")
    #   .end (sres) =>

    #     if sres.ok
    #       d = sres.body

    #       if d?
    #         if d.watchers_count < 20
    #           return res.send 400, { errros: { message: "#{d.full_name} has less than 20 watchers cannot add tag" } }

    #         search = ghId: d.id
    #         if req.body._id? && req.body.soId?
    #           search = soId: req.body.soId

    #         update =
    #           name: d.name
    #           short: d.name
    #           desc: d.description
    #           ghId: d.id
    #           gh:
    #             id: d.id
    #             name: d.name
    #             full: d.full_name
    #             watchers: d.watchers_count
    #             language: d.language
    #             owner:
    #               id: d.owner.id
    #               login: d.owner.login
    #               url: d.owner.url
    #               avatar: d.owner.avatar_url

    #           tokens: "#{d.full_name}"

    #         #console.log 'update', update

    #         return @model.findOneAndUpdate search, update, { upsert: true }, (e, r) ->
    #           res.send r

    #     return res.send 400, { errros: { message: sres.text } }
