async = require 'async'
winston = require 'winston'
neo4j = require 'neo4j'
chatter = require './services/chatterService'
rel = require './services/relationshipService'
neoService = require './services/neoService'

process.on 'uncaughtException', (err) ->
    console.log 'Caught exception: ' + err.stack

global.db = new neo4j.GraphDatabase(process.env.NEO4J_URL || 'http://localhost:7474');

async.waterfall [    
    #Authenticate to Salesforce.com API
    (callback) ->
        chatter.authenticate callback
    ,
    #Start with a clean graph database
    (callback) -> 
        neoService.purgeGraph callback
    ,
    #get all the users from the API
    (purgeResponse, callback) ->
        chatter.getUsers callback
    ,
    #create a node in the graph for each user
    (users, callback) ->
        neoService.createUserNodes users, callback
    ,   
    #create relationships between the nodes, based on the chatter follows
    (users, callback) ->
        rel.createRelationships users, chatter, callback
    ],
    (err, result) ->
        winston.info "ended with : #{err or result}"