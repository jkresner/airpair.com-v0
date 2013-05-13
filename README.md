About
===============================================================================

site @ http:///www.airpair.com/


Branching strategy + pull requests
===============================================================================

- master: is ongoing development branch

- prod: represents the current deployed code @ airpair.com

- prod milestones are tagged with

    `git tag release/v0.M.m.x prod`

- prod reverts can be achieved using

    `git checkout -b prod release/v0.M.m.x prod`

- ALL work is to be done on topic branches & merged into master w pull requests


To setup + run locally
===============================================================================

1)   npm install brunch -g

2)   Have mongoDB installed

3)   mongod

4)   npm install

5)   brunch w -s      (or  brunch watch --server)

6)   http://localhost:3333/



Running tests
===============================================================================

### Two types of tests

1) /test/server

   Runs inside node with mocha (things like api tests)

   ```mocha test/server/all.coffee

2) /test/integration

   hit html & make http requests either in browser or w PhantomJS
   First run brunch in test mode (test db/users etc.)

   ```brunch w -s -c config-test

   Then execute tests
   ```http://localhost:3333/test/index.html (in browser w mocha)
   ```mocha-phantomjs http://localhost:3333/test/index.html (in terminal with mocha-phantomjs)

### Pre-push git hook testing

Tests should be run on every push, to setup locally

  ```cd .git/hooks
     ln -nsf ../../build/git-hooks/pre-push

### Setup tests for mocha-phantomjs invocation

1) Install PhantomJS

2) npm install -g mocha-phantomjs

### Useful links

docs on expect syntax                chaijs.com/api/bdd/
docs on using spy/fake/stub          sinonjs.org/docs/
docs on sinon chai syntax            chaijs.com/plugins/sinon-chai


List of TODO next
===============================================================================

- [H] Transactional email
- [H] Deploy Error logging / mailing
- [H] Admin
  - [H] Review Request as Customer
- [H] Expert Review
  - [H] Email notification to customer

Deploy:

- setup git hook, for front + back tests


TODO v.5
===============================================================================

- [H] Split expert sign up into contact & prefs
- [H] Write Test for update request
- [M] Pull out hasLink and mail body saving to request/suggestion
- [H] Ask if request can be farmed out to the public
- [M] No suggested experts, signup / shared / refer
- [M] improve tag search
- [H] Show server error states for customer + expert sign in
- [M] Protect api calls for owners of objects
- [M] Mobile homepage
- [M] Add github projects to tags
- [H] Scheduling
  - [M] Timezones
- Remove experts with un-associated userIds (haven't logged in)
- [M] Airpair techniques emails (How to intro, share code etc.)


TODO low priority
===============================================================================

- [M] Downsize mongoHQ
- [L] Try out two instances with redis
- [Pete] consider flow: http://nvie.com/posts/a-successful-git-branching-model


Ideas to airpair on
===============================================================================

[Jake Verbaten]
- Mix panel & error logs pie chart

[Un-assigned]
- Update schema: https://github.com/visionmedia/node-migrate