#$log 'Stubs.base'

@stubs ?= {}

@stubs.siteUrl = "http://airpair.co/"

@stubs.dates =
  todayEpoch: new Date().getTime()
  nextweekEpoch: new Date(new Date().getTime() + (7*24*60) * 60000).getTime()
  lastweekEpoch: new Date(new Date().getTime() - (7*24*60) * 60000).getTime()
  twoweeksagoEpoch: new Date(new Date().getTime() - 2*(7*24*60) * 60000).getTime()
  lastmonthEpoch: new Date(new Date().getTime() - 4*(7*24*60) * 60000).getTime()
  threemonthsagoEpoch: new Date(new Date().getTime() - 12*(7*24*60) * 60000).getTime()
  sixmonthsagoEpoch: new Date(new Date().getTime() - 24*(7*24*60) * 60000).getTime()
  feb01: new Date 'Feb 01, 2013'
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
  feb24: new Date 'Feb 24, 2013'
  feb25: new Date 'Feb 25, 2013'
  feb26: new Date 'Feb 26, 2013'
  feb27: new Date 'Feb 27, 2013'
  feb28: new Date 'Feb 28, 2013'
  mar01: new Date 'Mar 01, 2013'
  mar02: new Date 'Mar 02, 2013'
  mar03: new Date 'Mar 03, 2013'
  mar04: new Date 'Mar 04, 2013'
  mar05: new Date 'Mar 05, 2013'
  mar06: new Date 'Mar 06, 2013'
  mar07: new Date 'Mar 07, 2013'
  mar08: new Date 'Mar 08, 2013'
  mar09: new Date 'Mar 09, 2013'
  mar10: new Date 'Mar 10, 2013'
  mar11: new Date 'Mar 11, 2013'
  mar12: new Date 'Mar 12, 2013'
  mar13: new Date 'Mar 13, 2013'
  mar14: new Date 'Mar 14, 2013'
  mar15: new Date 'Mar 15, 2013'
  mar16: new Date 'Mar 16, 2013'
  mar17: new Date 'Mar 17, 2013'
  mar18: new Date 'Mar 18, 2013'
  mar19: new Date 'Mar 19, 2013'


#require './skills'
