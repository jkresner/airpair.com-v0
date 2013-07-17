tagsData = require './test/data/tags'
tagModel = require './lib/models/tag'

module.exports = (app) ->

	app.use require('./test/server/test-passport').initialize app

	app.get '/seeddata', (req, res)-> 
		count = 0;
		for tag in tagsData
			mTagData =
				name: tag.name
				short: tag.short
				desc: tag.desc
				soId: tag.soId
				ghId: tag.ghId
				tokens: tag.tokens
			
			newTag = new tagModel(mTagData)
			newTag.save (err) ->
				count++
				if count == tagsData.length then res.send(200)

	app.get '/unseeddata', (req, res) -> 
		tagModel.remove () ->