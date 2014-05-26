module.exports = (expert) ->
  props = ['_id','userId','rate','pic','name','username','email','gmail','tags',
    'paymentMethod','homepage', 'gh.username', 'so.link', 'bb.id', 'in.id','tw.username']

  e = _.pickNested expert, props
  tags = []
  tags.push {short:t.short} for t in e.tags
  e.tags = tags
  e
