request = require 'superagent'
model = require './../models/tag'
tagdata = require './../../test/data/stackoverflow/tags'

model.find({}).remove()


module.exports = ->

  for i in [1...50]
    vector = ''
    for j in [0...40]
      idx = i * j
      vector += encodeURIComponent(tagdata[idx].name) + ';'
    console.log 'vector', vector

    request
      .get("http://api.stackexchange.com/tags/#{vector}/wikis?site=stackoverflow")
      .end (sres) =>

        if sres.ok
          batch = sres.body.items

          for d in batch

            update =
              name: d.tag_name
              short: d.tag_name
              soId: d.tag_name
              desc: d.excerpt

            console.log 'update', update

            return model.findOneAndUpdate soId: d.tag_name, update, { upsert: true }, (e, r) ->