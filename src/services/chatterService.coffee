_ = require 'underscore'
winston = require 'winston'
request = require 'request'
config = require '../config'
nforce = require 'nforce'
rel = require './relationshipService'

org = null

authenticate = (callback) ->
    conn =
        clientId: process.env.roauth_client_key
        clientSecret: process.env.roauth_client_secret
        redirectUri: process.env.roauth_callback
        apiVersion: 'v28.0'
        environment: 'production'
        mode: 'single'

    org = nforce.createConnection conn    

    userpass = 
        username: process.env.roauth_username
        password: process.env.roauth_password

    org.authenticate userpass, (err, resp) ->
        if !err 
            org.oauth = resp

            console.log 'Cached Token: ' + org.oauth.access_token
            callback null
        else
            callback err

getUsers = (callback) ->
    url = org.oauth.instance_url + '/services/data/v28.0/chatter/users'
    console.log 'getUsers url: ' + url
    opt =
        headers:
            Authorization: 'OAuth ' + org.oauth.access_token
    request.get url, opt, (error, response, body) ->
        if error
            callback "failed to retrieve users: #{error}"
        else if response.statusCode == 200
            winston.info "body = #{body}"
            b = JSON.parse body
            callback null, b.users
            #_.each b.users, (element, index, list) ->
            #   console.log element.name
        else
            callback "Not really an error... but also not a 200"


getFollowees = (user, callback) ->
    url = org.oauth.instance_url + "/services/data/v28.0/chatter/users/#{user.id}/following?&filterType=005"
    console.log 'getFollowees url: ' + url
    opt =
        headers:
            Authorization: 'OAuth ' + org.oauth.access_token
    request.get url, opt, (error, response, body) ->
        if error
            callback "Could not get followees #{error}"
        else if response.statusCode == 200
            winston.info "follwees found: #{_.size(JSON.parse(body).following)}"
            callback null, body
        else
            callback "Not really an error... but also not a 200"

module.exports = 
    authenticate: authenticate
    getFollowees: getFollowees
    getUsers: getUsers
