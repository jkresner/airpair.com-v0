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
  - [M] Request
- [H] Admin
  - [H] Basic dashboard
  - [H] Update Request
    - [H] assign devs
  - [H] Review Request
- [H] Beautify customer sign up
  - [H] Resolve availability
  - [H] View airpair
  - [H] Write Test for update airpair
  - [M] Enforce validation on contact details (e.g. name!)
  - [M] get error states
  - [M] iron bugs
- [H] Beautify dev sign up
  - [H] show fail to move forward because of username
  - [H] split into contact & prefs
  - [M] get error states
- [H] User Dashboard
  - [H] requests for help
  - [H] requests helping
- [H] Expert Review
  - [H] Respond to request
  - [H] Email notification to customer

Deploy:

- Tests for tags import
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
- Think about request event array

-------------------------------------------------------------------------------
List to airpair
===============================================================================

[Jared]
- Consider cost of passport session deserializing on every api call
- Ajax style OAuth flow
- redirectTo ?
- What type of testing can I do?
[Paul]
- How to run brunch to rebuild automatically when in node mode
- How to run serverside & clientside tests
[Peter Lyons]
- Sending mail
- Error handling
- Dates with mongo
- collecting JS dates
  - http://momentjs.com/
[Un-assigned]
- How to rename a mongo collection
  - mongo shell: db.requests.renameCollection( newName , <dropTarget> ) renames the collection.
- How to update schema
  - https://github.com/visionmedia/node-migrate
