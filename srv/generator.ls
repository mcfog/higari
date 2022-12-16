stream = require \stream
qiniu = require \qiniu

Promise = require \bluebird
getList = require \./ojisan/list
getDetail = require \./ojisan/detail

fs = require \fs
pfs = Promise.promisifyAll fs

[qiniu.conf.ACCESS_KEY, qiniu.conf.SECRET_KEY] = (process.env.QINIU || "").split /:/
BUCKET_NAME = process.env.QINIU_BUCKET
OUTPUT_HOME = process.env.OUTPUT_HOME

export populateIndex
export populateSeason
export warmup
export currentSeasons
export oldSeasons

function warmup seasons = currentSeasons!
  console.log 'start warmup'

  Promise.reduce [,...seasons], (, [year, month])->
    populateSeason "#{year}-#{month}"
    .then ->
      upload "#{year}-#{month}.json", (JSON.stringify it) 

  .then ->
    populateIndex!then ->
      upload "index-all.json", (JSON.stringify it) 

  .then ->
    console.log 'end warmup'

function upload name, content
  new Promise (resolve)->
    err, fp <- fs.open "#{OUTPUT_HOME}/#{name}", "w"
    throw that if err
    <- fs.write fp, content
    <- fs.close fp

    resolve!


function uploadQiniu name, content
  rs = new stream.Readable
    ..push content
    ..push null
    
  putPolicy = new qiniu.rs.PutPolicy "#{BUCKET_NAME}:#{name}"
  extra = new qiniu.io.PutExtra
  
  (Promise.promisify qiniu.io.putReadable) putPolicy.token!, name, rs, extra

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

    newYear = season[0]
    while offset < 0
        offset += 4
        newYear -= 1
    newMonth = season[1] + 3 * offset
    newYear += parseInt(newMonth / 12)
    newMonth = newMonth % 12

    [newYear, newMonth]

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
      
function populateSeason season
  getList "/anime/browser/airtime/#{season}"
  .map (entry)->
    getDetail entry.id
    .then ->

      it.hentai = 
        (it.tags.filter -> -1 isnt ['里番', '肉番', 'H', '18禁']indexOf it.text)length > 0
        and !it.wiki.some -> -1 isnt it.key.indexOf '电视台'
      delete it.wiki
      delete it.summary
      delete it.character
      delete it.relation
      it.tags.forEach -> delete it.href

      entry.detail = it
    .then -> entry
