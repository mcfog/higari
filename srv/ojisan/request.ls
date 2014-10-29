Promise = require \bluebird
cheerio = require \cheerio
request = require \request
redis = Promise.promisifyAll require \redis

prequest = Promise.promisify request

PREFIX = 'bgmpage:';

function open
  (Promise.resolve redis.createClient!)disposer ->
    it.quit!

option =
  pool: {maxSockets: 5}

module.exports = (url, expire = 3600)->
  #randomize expire
  expire = parseInt expire * (2.7 + 0.6 * Math.random!)

  cacheKey = "#{PREFIX}#{url}"

  client <- Promise.using open!

  client.getAsync cacheKey
  .then ->
    it || prequest url, option
#    prequest url, option
    .spread (req, body)->
      throw new Error 'content malformed' if -1 is body.indexOf 'bangumi'

      client.setexAsync cacheKey, expire, body
      .return body
  .then ->
    cheerio.load it