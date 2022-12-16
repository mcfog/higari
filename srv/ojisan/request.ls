Promise = require \bluebird
cheerio = require \cheerio
request = require \request
{RateLimiter} = require \limiter

limiter = new RateLimiter({ tokensPerInterval: 5, interval: 1000 });

prequest = Promise.promisify request

option =
  pool: {maxSockets: 5}

module.exports = (url)->
  Promise.resolve limiter.removeTokens 1
  .then ->
    req url

function req url
  prequest url, option
  .spread (, body)->
    throw new Error "content malformed of #{url}\n#{body}" if -1 is body.indexOf 'bangumi'

    body

  .then ->
    cheerio.load it
