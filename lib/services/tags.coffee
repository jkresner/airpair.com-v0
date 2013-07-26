request = require 'superagent'
DomainService   = require './_svc'

module.exports = class TagsService extends DomainService

  model: require './../models/tag'

  search: (searchTerm, callback) ->
    # Poor implementation of search, should checkout mongo-text-search or elastic-search
    @model.findOne { $or: [ { soId: searchTerm }, { ghId: searchTerm } ] }, (e, r) -> callback r

  create: (addMode, tag, callback) ->
    #console.log 'create', 'addMode', addMode
    if addMode is 'stackoverflow' then @getStackoverflowTag(tag, callback)
    else if addMode is 'github' then @getGithubRepo(tag, callback)
    else @model( tag ).save (e, r) -> 
      callback e, r

  getStackoverflowTag: (tag, callback) =>
    encoded = encodeURIComponent tag.nameStackoverflow

    request
      .get("http://api.stackexchange.com/tags/#{encoded}/wikis?site=stackoverflow")
      .end (sres) =>

        if sres.ok
          d = sres.body.items[0]

          if d?
            update =
              name: d.tag_name
              short: d.tag_name
              soId: d.tag_name
              desc: d.excerpt

            return @model.findOneAndUpdate soId: d.tag_name, update, { upsert: true }, (e, r) ->
              callback e, r

        # console.log 'failed', sres.body
        return callback { message: "tag #{tag.nameStackoverflow} found" }

  getGithubRepo: (tag, callback) =>

    request
      .get("https://api.github.com/repos/#{tag.nameGithub}")
      .end (sres) =>
        if sres.ok
          d = sres.body
          if d?
            if d.watchers_count < 20
              return callback { message: "Can not add #{d.full_name} as it has less than 20 watchers." }

            update = null

            if tag._id?
              search = _id: tag._id

              update =
               ghId: d.id
               gh:
                id: d.id
                name: d.name
                full: d.full_name
                watchers: d.watchers_count
                language: d.language
                owner:
                  id: d.owner.id
                  login: d.owner.login
                  url: d.owner.url
                  avatar: d.owner.avatar_url

            else
              update =
                name: d.name
                short: d.name
                desc: d.description
                ghId: d.id
                gh:
                  id: d.id
                  name: d.name
                  full: d.full_name
                  watchers: d.watchers_count
                  language: d.language
                  owner:
                    id: d.owner.id
                    login: d.owner.login
                    url: d.owner.url
                    avatar: d.owner.avatar_url
                tokens: "#{d.full_name}"
 
            return @model.findOneAndUpdate search, update, { upsert: true }, (e, r) ->
              callback e, r
        # failed - tag not found
        return callback { message: "tag #{tag.nameGithub} not found" }

  #getGithubRepo: (tag, callback) =>
  #  throw new Error 'gittag not implemented'
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
