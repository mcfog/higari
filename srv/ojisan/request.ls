Promise = require \bluebird
cheerio = require \cheerio
request = require \request

prequest = Promise.promisify request

option =
  pool: {maxSockets: 5}

module.exports = (url)->
  prequest url, option
  .spread (, body)->
    throw new Error 'content malformed' if -1 is body.indexOf 'bangumi'

    body

  .then ->
    cheerio.load it
