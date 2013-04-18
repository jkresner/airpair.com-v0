request = require 'superagent'
CRUDApi = require './_crud'

Tag = require './../models/tag'
Tag.find({}).remove()

class TagsApi extends CRUDApi

  model: require './../models/tag'


  create: (req, res) =>
    console.log 'create', 'addMode', req.body.addMode
    if req.body.addMode is 'stackoverflow' then @getStackoverflowTag(req, res)
    else if req.body.addMode is 'github' then @getGithubRepo(req, res)
    else @model( req.body ).save (e, r) -> res.send r


  getStackoverflowTag: (req, res) =>
    encoded = encodeURIComponent req.body.nameStackoverflow

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

#            console.log 'update', update

            return @model.findOneAndUpdate soId: d.tag_name, update, { upsert: true }, (e, r) ->
              res.send r

        return res.send 400, { errros: { message: sres.text } }


  getGithubRepo: (req, res) =>

    request
      .get("https://api.github.com/repos/#{req.body.nameGithub}")
      .end (sres) =>

        if sres.ok
          d = sres.body

          if d?
            if d.watchers_count < 20
              return res.send 400, { errros: { message: "#{d.full_name} has less than 20 watchers cannot add tag" } }

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

            #console.log 'update', update

            return @model.findOneAndUpdate ghId: d.id, update, { upsert: true }, (e, r) ->
              res.send r

        return res.send 400, { errros: { message: sres.text } }



module.exports = (app) -> new TagsApi(app,'tags')