async = require 'async'
_ = require 'underscore'
winston = require 'winston'
neo4j = require 'neo4j'

purgeGraph = (callback) -> 
    winston.info 'would have cleared graph' #neo.clearGraph callback
    callback null, 'X cleared'

getNodeByExternalId = (externalId, callback) -> 
    winston.info "Searching for node by externalId (#{externalId})"
    global.db.getIndexedNode 'chatter_users', 'externalId', externalId, callback

createUserNode = (user, callback) ->
    n =
        name: user.name
        externalId: user.id
    async.waterfall [
        (callback) -> 
            winston.info "Searching for node by externalId (#{n.externalId})"
            global.db.getIndexedNode 'chatter_users', 'externalId', n.externalId, callback
        ,
        (node, callback) -> 
            if node
                winston.info "Found node #{node.id} with externalId (#{n.externalId}), using that"
                callback(null, false, node)
            else
                winston.info "creating node for #{n.name} (#{n.externalId})"
                node = global.db.createNode n
                node.save (err, node) ->
                    callback err, true, node
        ,
        (isNew, node, callback) ->
            if isNew
                winston.info "creating index for node for #{n.externalId}"
                node.index 'chatter_users', 'externalId', n.externalId, callback
            else
                callback null, node
        ]
        ,callback

createUserNodes = (users, callback) ->
    async.eachLimit users, 2, createUserNode.bind(createUserNode), (err) -> 
        callback err, users

getShortestPath = (fromNode, toNode, callback) ->
    fromNode.path toNode, 'FOLLOWS', 'out', 5, 'shortestPath', callback

module.exports = 
    getNodeByExternalId: getNodeByExternalId
    createUserNode: createUserNode
    createUserNodes: createUserNodes
    purgeGraph: purgeGraph
    getShortestPath: getShortestPath


