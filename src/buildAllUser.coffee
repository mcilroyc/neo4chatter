async = require 'async'
_ = require 'underscore'
winston = require 'winston'
chatter = require './services/chatterService'

getAllUsersLight = (callback) ->
    async.waterfall [    
        (callback) ->
            chatter.authenticate callback
        ,
        (callback) ->
            winston.info "about to fetch all users"
            chatter.getUsers callback
        ]
        ,
        (err, result) ->
            if err
                callback err
            else
                winston.info "size of users: #{_.size result}"
                u = _.map result, (num, key) ->
                    winston.info "num : #{num}, key: #{key}"
                    d =
                        id: num.id
                        name: num.name
                    return d
                winston.info "users = #{JSON.stringify u}"
                callback null, u 

module.exports = 
    getAllUsersLight: getAllUsersLight