getList = require \../ojisan/list
getDetail = require \../ojisan/detail

app <- ->
  module.exports = it

req, res, next <- app.get /^\/rank\/season\/(\d{4}-\d{1,2}).json/

getList "/anime/browser/airtime/#{req.params.0}"
.map (entry)->
  getDetail entry.id
  .then ->
    entry.detail = it

    entry

.then -> res.json it
.timeout 30_000
.catch ->
  console.error it
  res.end it.toString!
