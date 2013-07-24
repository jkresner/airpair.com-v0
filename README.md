About
===============================================================================

site @ http://www.airpair.com/


Branching strategy + pull requests
===============================================================================

- **master** is ongoing development branch

- **prod** represents the current deployed code @ airpair.com

- ***milestones*** are tagged with

    `git tag release/v0.M.m.x prod`

- ***reverts*** can be achieved using

    `git checkout -b prod release/v0.M.m.x prod`

- ALL work is to be done on topic branches & merged into master w pull requests


To setup + run locally
===============================================================================

1)   Install mongoDB

1)   Install brunch.io `npm install brunch -g`

3)   Run mongo `mongod`

4)   Install npm package `npm install`

5)   Run brunch server `brunch w -s` or `brunch watch --server`

6)   Open browser @ http://localhost:3333/

7)   For testing, install PhantomJS & mocha-phantomjs `npm install -g mocha mocha-phantomjs phantomjs`


Running tests
===============================================================================

#### Two types of tests

##### 1. /test/server

   Runs in node with mocha (e.g api tests)

   `mocha test/server/all.coffee`

##### 2. /test/integration

   hit html & make http requests either in browser or w PhantomJS

   First run brunch in test mode (test db/users etc.)

   `brunch w -s -c config-test`

   Then execute tests

   `http://localhost:4444/test/index.html` (in browser w mocha)

   `mocha-phantomjs http://localhost:4444/test/index.html` (in terminal w mocha-phantomjs)

#### Pre-push git hook testing

Tests should run on every push. To setup locally

  `cd .git/hooks`

  `ln -nsf ../../build/git-hooks/pre-push`

#### Useful links

- docs on expect syntax                chaijs.com/api/bdd/
- docs on using spy/fake/stub          sinonjs.org/docs/
- docs on sinon chai syntax            chaijs.com/plugins/sinon-chai


List of TODO next (v.6)
===============================================================================

- [H] Admin schedule call & redeem hours
- [H] "Book me" flows
- [H] Transactional email
- [H] Schedule / google calendar integration
  - [M] Timezone calculator
- [M] Add linkedIn airpair share
- [H] Split expert sign up into contact & prefs
- [H] Ask if request can be farmed out to the public
- [M] Add github projects to tags
- [M] improve tag search
- [L] Remove experts with un-associated userIds (haven't logged in)
- [L] Pull out hasLink and mail body saving to request/suggestion

TODO v.7
===============================================================================

- [H] Chat / User to user messaging system
- [H] Show server error states for customer + expert sign in
- [M] Mobile homepage
- [L] Airpair techniques emails (How to intro, share code etc.)

TODO low priority
===============================================================================

- [L] Try two instances with redis ?
- [L] Downsize mongoHQ

Ideas to airpair on
===============================================================================

[Jake Verbaten]
- Mix panel & error logs pie chart

[Un-assigned]
- Update schema: https://github.com/visionmedia/node-migrate
