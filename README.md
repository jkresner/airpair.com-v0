About
===============================================================================

http://www.airpair.com/

Architecture walk through => http://youtu.be/e0N_2T7Tdf8


Branching strategy + pull requests
===============================================================================

- ALL work is to be done on topic branches & merged into master w pull requests

- **master** is ongoing development branch

- **prod** represents the current deployed code @ airpair.com

- ***milestones*** are tagged with

    `git tag release/v0.M.m.x prod`

- ***reverts*** can be achieved using

    `git checkout -b prod release/v0.M.m.x prod`


To setup + run locally
===============================================================================

1)   Install mongoDB

1)   Install brunch.io & coffee-script `npm install brunch coffee-script -g`

3)   Run mongo `mongod`

4)   Install npm package `npm install`

5)   Run brunch server `brunch w`

6)   Open browser @ http://localhost:3333/

7)   For testing, install PhantomJS & mocha-phantomjs `npm install -g mocha mocha-phantomjs phantomjs`

8)   Run "npm run hooks" to set up the pre-push hooks"


Running tests
===============================================================================

#### Two types of tests

##### 1. /test/server

   Runs in node with mocha (e.g api tests)

   `mocha test/server/all.coffee`

##### 2. /test/integration

   hit html & make http requests in browser or w PhantomJS

   1) Run brunch in test mode (test db/users etc.)

     `brunch w -e test`

   2) Then execute tests

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


CSS Structure
===============================================================================

CSS lives in 3 places

1)  '/vendor/styles'
    Vendor

2)  `/app/assets/css`
    Gets copied to /public/css and read as is

3)  `/app/css`
    Gets compiles and combined per settings in `/config.coffee`

Files structured and combined into:

-   [ap.css]
    `/app/styles/ap/*css`
    `/app/styles/shared/*css`
    Styles for front end inheriting the WordPress epik theme which is an exact copy of the one served from the blog at
    `http://www.airpair.com/wp-content/themes/epik/style.css`

  ( if dev node offline, can't work+ slower to load )
  ( Add hack in dev to read local-copy ) | (PROB can't pull https: YET) )

--- [adm.css]
    `/app/styles/adm/*css`
    `/app/styles/shared/*css`
    Styles and page layout relevant to "backend" administrator pages inheriting from bootstrap.


Random Notes
===============================================================================

### Common gotcha's while writing phantomJS integration tests
- the view redirects on success. solution: `v.renderSuccess = ->`
- the view hasnt loaded data yet; wait for the models/collections to sync
- the story's step does not exist
- the story's step uses the wrong router
