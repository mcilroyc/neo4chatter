async = require 'async'
_ = require 'underscore'
winston = require 'winston'
neoService = require './neoService'

#placeholder
chatter = null

createUserRelationship = (sNode, followee, callback) ->
    async.waterfall [
        (callback) ->
            #winston.info("help: " + JSON.stringify followee )
            neoService.createUserNode followee?.subject, callback
        ,
        (node, callback) ->
            winston.info "creating relationshiop from node #{sNode.id} to node #{node.id}"
            sNode.createRelationshipTo(node, 'FOLLOWS', null, callback)
        ],
        (err, result) -> callback err, 'created relationship: ' + result

createUserRelationships = (user, callback) ->
    #call chatter API
    winston.info 'calling getFollowees for ' + user.name
    async.waterfall [
        (callback) ->
            neoService.createUserNode user, callback
        ,
        (sNode, callback) -> 
            chatter.getFollowees user, (err, body) ->
                callback err, sNode, body     
        ,
        (sNode, body, callback) ->
            b = JSON.parse(body)
            #winston.info user.name + ' follows ' + _.pluck(_.pluck(b.following, 'subject'),'name')
            #TODO: evaluate whether the following approach is correct.  seems a bit odd to have to pass that param through bind...
            async.eachLimit b.following, 2,  createUserRelationship.bind(createUserRelationship, sNode), (err) ->
                callback(err, 'finished all users')
        ],
        (err, result) -> callback err, 'created relationships:' + result
    
       

createRelationships = (users, _chatter, callback) ->
    chatter = _chatter
    async.eachLimit users, 2, createUserRelationships.bind(createUserRelationships), (err) -> 
        callback(err, 'finished all users')

module.exports = 
    createRelationships: createRelationships


