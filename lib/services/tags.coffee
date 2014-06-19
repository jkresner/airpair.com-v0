request       = require 'superagent'
DomainService = require './_svc'


module.exports = class TagsService extends DomainService

  logging: on

  model: require './../models/tag'

  getBySoId: (id, cb) ->
    $log 'getBySoId', id, @searchOne
    @searchOne { soId: id }, {}, cb

  create: (addMode, tag, callback) ->
    # console.log 'create', 'addMode', addMode, tag
    if addMode is 'stackoverflow' then @getStackoverflowTag(tag, callback)
    else if addMode is 'github' then @getGithubRepo(tag, callback)
    else @model( tag ).save callback


  getStackoverflowTag: (tag, callback) =>
    encoded = encodeURIComponent tag.nameStackoverflow
    request
      .get("http://api.stackexchange.com/tags/#{encoded}/wikis?site=stackoverflow")
      .end (res) =>
        error = new Error "tag #{tag.nameStackoverflow} not found"

        if !res.ok then return callback error

        d = res.body.items[0]

        if !d then return callback error

        update =
          name: d.tag_name
          short: d.tag_name
          soId: d.tag_name
          desc: d.excerpt

        @model.findOneAndUpdate soId: d.tag_name, update, { upsert: true }, callback


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
