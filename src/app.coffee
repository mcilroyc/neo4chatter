express = require 'express'
async = require 'async'
_ = require 'underscore'
winston = require 'winston'
neo4j = require 'neo4j'
config = require './config'
neoService = require './services/neoService'
#fb_parser = require 'fb-signed-parser'
sfdc_parser = require './sfdc-request-parser'
userService = require './buildAllUser'

#spin up neo4j connection
global.db = new neo4j.GraphDatabase(process.env.NEO4J_URL || 'http://localhost:7474');

#this
process.on 'uncaughtException', (err) ->
    console.log 'Caught exception: ' + err.stack

# configure the server
app = express()

#config
app.set 'title', config.server_name
app.set 'view engine', 'html'
app.engine 'html', require('hbs').__express

# enable expres plugins
app.use express.json()
app.use express.urlencoded()
app.use express.static('public')

app.post '/', (req, res) ->
    winston.info "body: #{_.keys req?.body}"
    signed_request = req?.body?.signed_request
    winston.info "signed_request: #{req?.body?.signed_request}"
    data = sfdc_parser.parse(signed_request, process.env.oauth_client_secret);
    winston.info "body: #{data}"
    userService.getAllUsersLight (err, users) ->
        if !err
            pageData = 
                canvasRequestPretty: 
                    JSON.stringify data, null, 4
                canvasRequest: 
                    JSON.stringify data
                allUsers: 
                    JSON.stringify users
                thisDomain:
                    process.env.this_domain
            #TODO make available instance/version so the proper canvas js file can be included in the index file
            winston.info "keys: #{_.keys pageData}"
            res.render "index", pageData
        else
            res.send ("oops: #{err}")

app.get '/spoof', (req, res) ->
    data = require('./spoofData')
    userService.getAllUsersLight (err, users) ->
        if !err
            pageData = 
                canvasRequestPretty: 
                    JSON.stringify data, null, 4
                canvasRequest: 
                    JSON.stringify data
                allUsers: 
                    JSON.stringify users
                thisDomain:
                    process.env.this_domain
            #TODO make available instance/version so the proper canvas js file can be included in the index file
            winston.info "keys: #{_.keys pageData}"
            res.render "index", pageData
        else
            res.send ("oops: #{err}")

app.get '/shortestPath/:fromId/:toId', (req, res) ->
    async.waterfall [
        (callback) ->
            winston.info "calling getNodeByExternalId with #{req.params.fromId}"
            neoService.getNodeByExternalId req.params.fromId, callback
        ,
        (fromNode, callback) ->
            winston.info "calling getNodeByExternalId with #{req.params.toId}"
            neoService.getNodeByExternalId req.params.toId, (err, toNode) -> 
                callback err, fromNode, toNode
        ,
        (fromNode, toNode, callback) ->
            winston.info "calling getShortestPath with #{fromNode.id} -> #{toNode.id}"
            neoService.getShortestPath fromNode, toNode, callback
        ],
        (err, result) -> 
            winston.info "shortest path result : #{err or result}"
            if err
                res.send err
            else
                if req.query.fullout
                    res.send result
                else
                    cleanResults =
                        pathLength : result._length
                        relationships : _.pluck(_.pluck(result._relationships,'_data'),'self')
                    res.json cleanResults
    

# start the server
app.listen port = process.env.PORT ? 3333
winston.info "#{app.get 'title'} listening at #{port}"