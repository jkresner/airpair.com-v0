About
===============================================================================

site @ airpair.com


-------------------------------------------------------------------------------
Branching strategy + pull requests
===============================================================================

- master: is ongoing development branch

- prod: represents the current deployed code @ airpair.com

- prod milestones are tagged with

    `git tag release/v0.M.m.x prod`

- prod reverts can be achieved using

    `git checkout -b prod release/v0.M.m.x prod`

- ALL work is to be done on topic branches & merged into master w pull requests


-------------------------------------------------------------------------------
Setup + run locally
===============================================================================

1)   npm install brunch -g

2)   Make sure you have mongoDB installed

3)   mongod

4)   brunch w -s      (or  brunch watch --server)

5)   http://localhost:3333/


-------------------------------------------------------------------------------
Test
===============================================================================

Three layers of tests:

- /ui (JS front end only)
- /integration (JS front end calling server side, should have no deps on node)
- /server (Node only)

1)   npm install -g mocha

2)   npm install -g mocha-phantomjs

3)   brunch w -s

4)   mocha-phantomjs http://localhost:3333/test/index.html   (front end tests)

5)   mocha test/server (backend tests)


-------------------------------------------------------------------------------
List of TODO
===============================================================================

Dev Min:

- [H] Import v0.3 data
  - [H] Skills
  - [H] Devs
  - [M] Request
- [H] Admin
  - View devs
  - Basic dashboard
  - Update Request
    - assign devs
- [H] Beautify customer sign up
  - [H] Resolve availability
  - [M] get error states
  - [M] iron bugs
- [H] Beautify dev sign up
  - [H] show fail to move forward because of username
  - [H] split into contact & prefs
  - [M] get error states
- [H] User Dashboard
  - [H] requests for help
  - [H] requests helping
- [H] Expert Review + Respond to request

Deploy:

- Test auth against live configs
- Confirm persisted session
- Update heroku dyno size & mongodb size


Pre-deploy:

- Remove tokens from api/user/me
- Add stack overflow app icon
- Mobile homepage

-------------------------------------------------------------------------------
List of TODO v.5
===============================================================================

- Add github projects to tags
- Remove experts with un-associated userIds (haven't logged in)

-------------------------------------------------------------------------------
List to airpair
===============================================================================

- Consider cost of passport session deserializing on every api call
- How to run brunch to rebuild automatically when in node mode
- How to rename a mongo collection
  - mongo shell: db.requests.renameCollection( newName , <dropTarget> ) renames the collection.
- How to update schema
  - https://github.com/visionmedia/node-migrate
- Dates with mongo
- collecting JS dates
  - http://momentjs.com/