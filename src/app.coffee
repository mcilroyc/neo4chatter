express = require 'express'
winston = require 'winston'
config = require './config'
_ = require 'underscore'

# configure the server
app = express()

#config
app.set 'title', config.server_name

# enable expres plugins
app.use express.json()

app.post '/', (req, res) ->
  winston.info "body: #{req.body.blah}"
  res.send 'Hello World'

# start the server
app.listen port = process.env.PORT ? 3333
winston.info "#{app.get 'title'} listening at #{port}"