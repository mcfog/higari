Promise = require \bluebird
express = require \express
glob = require \glob

app = express!

(glob.sync "#{__dirname}/route/**/*.ls").forEach -> (require it) app


app.use express.static "#{__dirname}/../public"

port = process.env.PORT || 31024

module.exports = app.listen port, 'localhost', ->
  console.log "higari listen on #{port}"
