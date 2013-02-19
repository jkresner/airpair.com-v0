#$log 'Stubs.base'

@stubs ?= {}

@stubs.dates =
  todayEpoch: new Date().getTime()
  nextweekEpoch: new Date(new Date().getTime() + (7*24*60) * 60000).getTime()
  lastweekEpoch: new Date(new Date().getTime() - (7*24*60) * 60000).getTime()
  twoweeksagoEpoch: new Date(new Date().getTime() - 2*(7*24*60) * 60000).getTime()
  lastmonthEpoch: new Date(new Date().getTime() - 4*(7*24*60) * 60000).getTime()
  threemonthsagoEpoch: new Date(new Date().getTime() - 12*(7*24*60) * 60000).getTime()
  sixmonthsagoEpoch: new Date(new Date().getTime() - 24*(7*24*60) * 60000).getTime()
  feb1: new Date 'Feb 01, 2013'
  feb10: new Date 'Feb 10, 2013'
  feb15: new Date 'Feb 15, 2013'
  feb16: new Date 'Feb 16, 2013'
  feb17: new Date 'Feb 17, 2013'
  feb18: new Date 'Feb 18, 2013'
  feb19: new Date 'Feb 19, 2013'
  feb20: new Date 'Feb 20, 2013'
  feb21: new Date 'Feb 21, 2013'
  feb22: new Date 'Feb 22, 2013'
  feb23: new Date 'Feb 23, 2013'


require './skills'
require './developers'
require './admin'