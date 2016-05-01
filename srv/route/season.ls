generator = require \./generator

app <- ->
  module.exports = it

req, res, next <- app.get '/rank/index.json'


generator.populateIndex!then -> res.json it
.timeout 30_000
.catch ->
  console.error it
  res.end it.toString!
