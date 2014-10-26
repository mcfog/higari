Promise = require \bluebird
getList = require \../ojisan/list
getDetail = require \../ojisan/detail

setInterval warmup, 1800_000
setTimeout warmup

function warmup
  console.log 'start warmup'
  Promise.all currentSeasons!map ([year, month])->
    getList "/anime/browser/airtime/#{year}-#{month}"
    .map (entry)->
      getDetail entry.id

  .then ->
    console.log 'end warmup'


function currentSeasons

  now = new Date!
  month = [1,1,1,4,4,4,7,7,7,10,10,10]
  year = now.getFullYear!

  month = month[now.getMonth!]

  current = [year, month];
  seasons = [];


  [seasons.push seasonOffset current, o for o in [1 to -4]]

  seasons

function seasonOffset(season, offset)

    newYear = season[0]
    while offset < 0
        offset += 4
        newYear -= 1
    newMonth = season[1] + 3 * offset
    newYear += parseInt(newMonth / 12)
    newMonth = newMonth % 12

    [newYear, newMonth]

app <- ->
  module.exports = it

req, res, next <- app.get '/rank/index.json'

Promise.all currentSeasons!map ([year, month])->
  getList "/anime/browser/airtime/#{year}-#{month}"
  .then ->
    top = it.sort (a,b)->
      return -1 if !b.rate
      return 1 if !a.rate
      b.rate - a.rate
    .0

    {
      name: "#{year}年#{month}月"
      href: "/rank.html\#season/#{year}-#{month}"
      top
    }

.then -> res.json it
.timeout 30_000
.catch ->
  console.error it
  res.end it.toString!
