module.exports.logicalCat = """
<p>I have a Rails app + Ruby scripts that usually have to run on Windows and behave
like a desktop app. I've decided that the current combo is too bloated and too hard
to maintain, so I'm looking to rewrite it in node. My main motivation is to unify
the UI part (the Rails app) and the crawler script part (a bunch of Ruby scripts
managed by an .exe GUI wrapper) into a single node app. My secondary motivation
is to learn/reinforce best practices (BDD, etc) in node.js that I kinda ignored
when writing the first iteration in Rails.</p>
<p>I'm at the very beginning of this endeavor. Wrapping my head around node.js is
hard enough, and I would appreciate tips on how to structure the "web app + crawler
scripts + on Windows (!!)".</p>
<p>Also some pair programming with a node.js expert on a single crawler script would
be most helpful. I want to get going faster and avoid dead-ends!</p>
<p>more detail...</p>
<p>RAILS APP:</p>
<p>The online app is just a demo; the real thing runs on user's intranets (oil
companies are paranoid), usually 100% Windows. Yes, it is extremely painful
getting this running on Windows; I wrote an installer that gets Rails, the app
and ElasticSearch going, but ouch. It's horrid to support and try to sell.
The rails app itself is pretty vanilla and doesn't do much. It allows search
in ElasticSearch and presents some javascript vis stuff.</p>

<p>CRAWLERS:</p>
<p>The crawler scripts are the interesting part. For each data type (think seismic
files, petrophysical logs, various GIS map data, some vendor-specific weird databases,
etc.) I made a separate ruby gem. The gems run as command line tools with lots of
switches and (generally) push their output to ElasticSearch. My clients tend to be
not-quite-technical and are scared of running command line, so I wrote a janky GUI
to help manage the scripts...BUT they are still completely separate from the Rails app.
</p>

<p>COMBINE AND SIMPLIFY:</p>
<p>I've got nothing against Ruby/Rails, but I've just come to realize that I need to simplify
things greatly to be able to support and grow my business. For example, the Rails app has an
authentication layer that I envisioned being used in an online, hosted version of the app.
The reality is that none of my clients are going to trust "the cloud" any time soon, so all
that stuff (and support for encrypted S3 storage, etc.) is not necessary. Likewise, the crawlers
have all this extra functionality that never gets used.</p>

<p>I want users to be able to go to a single-page browser app (or perhaps one-page-per data
  type) and be able to configure and launch all their intranet crawling AND use
search/visualizations in one place.</p>
""";