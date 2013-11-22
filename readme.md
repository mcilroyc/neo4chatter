## Demo node.js / Canvas application using neo4j

This is a CoffeeScript node.js __demo application__ meant to show the use of Salesforce.com Canvas, The Chatter API and neo4j to create "social graph utilities".  It is not a complete application and should be used only for reference.

It indexes the "follows" in a Chatter organization and provides a "shortest path" utility.  There is also a statically generated D3 "Force-Directed Graph".

- This requires [neo4j](http://www.neo4j.org/) which is easily installed locally, or can be used with the free [Heroku addon](https://addons.heroku.com/neo4j#try)
- A sample.env file shows the environment variables used by the application
- A /spoof endpoint uses a static json file to simulate a Canvas signed request (for local testing).  You'll have to update it based on a snapshot of your Canvas application because the signature included here won' match your secret key