{ S3Client, PutObjectCommand } = require("@aws-sdk/client-s3")
stream = require \stream
Promise = require \bluebird
getList = require \./ojisan/list
getDetail = require \./ojisan/detail
fs = require \fs
pfs = Promise.promisifyAll fs

{OUTPUT_HOME, S3_ENDPOINT, S3_BUCKET} = process.env

export populateIndex
export populateSeason
export warmup
export currentSeasons
export oldSeasons

function warmup seasons = currentSeasons!
  console.log new Date(), 'start warmup', seasons

  Promise.reduce [,...seasons], (, [year, month])->
    populateSeason year, month
    .then ->
      upload "#{year}-#{month}.json", (JSON.stringify it) 

  .then ->
    populateIndex!then ->
      upload "index-all.json", (JSON.stringify it) 

  .then ->
    console.log new Date(), 'end warmup'


s3 = new S3Client {endpoint: S3_ENDPOINT}
function upload name, content
  cmd = new PutObjectCommand {
    Body: content
    Bucket: S3_BUCKET
    Key: name
    ContentType: 'application/json'
  }

  s3.send(cmd)

function uploadLocal name, content
  new Promise (resolve)->
    err, fp <- fs.open "#{OUTPUT_HOME}/#{name}", "w"
    throw that if err
    <- fs.write fp, content
    <- fs.close fp

    resolve!


function currentSeasons
  [seasonOffset currentSeason!, o for o in [1 to -4]]

function oldSeasons
  [seasonOffset currentSeason!, o for o in [-5 to -14]]

function currentSeason
  now = new Date!
  month = [1,1,1,4,4,4,7,7,7,10,10,10]
  year = now.getFullYear!

  month = month[now.getMonth!]

  [year, month]

function seasonOffset(season, offset)
    y = season[0]
    m = season[1] - 1 + 3 * offset
    while m < 0
        m += 12
        y -= 1
    y += parseInt(m / 12)
    m = m % 12

    [y, m + 1]

function populateIndex
  Promise.all [(seasonsIndex currentSeasons!), (seasonsIndex oldSeasons!)]
  .then ([current, old])->
    {current, old}
  
function seasonsIndex seasons
  Promise.all seasons.map ([year, month])->
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

function populateSeason(year, month)
  Promise.all [-1, 0, 1].map (x)->
    [y, m] = seasonOffset [year, month+x], 0
    getList "/anime/browser/airtime/#{y}-#{m}"
  .map (entries)->
    Promise.all entries.map (entry)->(getDetail entry.id).then ->
      it.hentai = 
        (it.tags.filter -> -1 isnt ['里番', '肉番', 'H', '18禁']indexOf it.text)length > 0
        and !it.wiki.some -> -1 isnt it.key.indexOf '电视台'
      delete it.wiki
      delete it.summary
      delete it.character
      delete it.relation
      it.tags.forEach -> delete it.href

      entry.detail = it
      entry
  .then -> it.flat!
    

