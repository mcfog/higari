generator = require \./generator

app <- ->
  module.exports = it

req, res, next <- app.get /^\/rank\/season\/(\d{4}-\d{1,2}).json/

generator.populateSeason req.params.0
.then -> res.json it
.timeout 30_000
.catch ->
  console.error it
  res.end it.toString!
