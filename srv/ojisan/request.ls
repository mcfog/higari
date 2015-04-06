Promise = require \bluebird
cheerio = require \cheerio
request = require \request
mongodb = require \mongodb

prequest = Promise.promisify request

COLLECTION = \cached;

function open
  (Promise.promisify mongodb.MongoClient.connect) "mongodb://localhost:27017/higari"
  .disposer ->
    it.close!

function pCall obj, method, args = []
  (Promise.promisify obj[method], obj)
  .apply null, args

option =
  pool: {maxSockets: 5}

Promise.using open!, (client)->
  args = [COLLECTION, {+capped, size: 100_000_000}];
  <- (pCall client, \createCollection, args)then

  args = [{
    createdAt: 1
  }, {
    expireAfterSeconds: 7200
  }]
  <- (pCall (client.collection COLLECTION), \ensureIndex, args)then


module.exports = (url, expire = 3600)->

  cacheKey = "#{PREFIX}#{url}"

  client <- Promise.using open!

  collection = client.collection COLLECTION

  pCall collection, \findOne, [{
    _id: url
  }]
  .then ->
    if it
      it.body
    else
      prequest url, option
      .spread (, body)->
        throw new Error 'content malformed' if -1 is body.indexOf 'bangumi'
        doc = {
          _id: url
          body
          createdAt: new Date
        }

        pCall collection, \insert, [doc]
        .return body
  .then ->
    cheerio.load it
