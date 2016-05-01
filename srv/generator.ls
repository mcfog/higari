stream = require \stream
qiniu = require \qiniu

Promise = require \bluebird
getList = require \./ojisan/list
getDetail = require \./ojisan/detail

[qiniu.conf.ACCESS_KEY, qiniu.conf.SECRET_KEY] = (process.env.QINIU || "").split /:/
BUCKET_NAME = process.env.QINIU_BUCKET

export populateIndex
export populateSeason
export warmup

function warmup
  console.log 'start warmup'

  Promise.reduce [,...currentSeasons!], (, [year, month])->
    populateSeason "#{year}-#{month}"
    .then ->
      upload "#{year}-#{month}.json", (JSON.stringify it) 

  .then ->
    populateIndex!then ->
      upload "index.json", (JSON.stringify it) 

  .then ->
    console.log 'end warmup'

function upload name, content
  rs = new stream.Readable
    ..push content
    ..push null
    
  putPolicy = new qiniu.rs.PutPolicy "#{BUCKET_NAME}:#{name}"
  extra = new qiniu.io.PutExtra
  
  (Promise.promisify qiniu.io.putReadable) putPolicy.token!, name, rs, extra

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

function populateIndex

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
      
function populateSeason season
  getList "/anime/browser/airtime/#{season}"
  .map (entry)->
    getDetail entry.id
    .then ->
      delete it.wiki
      delete it.summary
      delete it.character
      delete it.relation
      it.tags.forEach -> delete it.href

      entry.detail = it
    .then -> entry
