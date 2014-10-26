Promise = require \bluebird
req = require \./request

module.exports = (id)->
  $ <- (req "http://bgm.tv/subject/#{id}")then

  function text
    ($ it)text!
  function html
    ($ it)html!
  function href
    ($ it)attr \href
  function src
    ($ it)attr \src

  function mapArray sel, mapper
    $ sel .map mapper .toArray!

  function parseInfo
    $tip = $ '.tip', @ .remove!
    {
      key: $tip.text!replace /: /, ''
      value: $ @ .html!
      valueText: $ @ .text!
    }

  function parseAudience
    result = {}

    $ 'a', it .each ->
      result[href @ .replace /^.*\/(\w+)$/, '$1'] = parseInt text @

    result

  function parseTag
    href: href @
    text: text @
    count: parseInt ($ @)next!text!replace /^.*(\d+).*$/, '$1'

  function parseRate
    rate: text $ '.label', @
    count: parseInt ((text $ '.count', @)slice 1, -1)

  function parseCharacter
    name: text $ 'a.avatar', @ .trim!
    nameCN: text $ 'span.tip', @
    plus: parseInt (text $ 'small.fade', @).slice 2, -1
    avatar: src $ 'img.avatar', @
    job: text $ '.badge_job', @
    cv: mapArray ($ '[rel="v:starring"]', @), ->
      href: href @
      name: text @

  function parseRelation
    type: with (text $ '.sub', @) || parseRelation.type
      parseRelation.type = ..
    cover: ($ '.avatarNeue', @)attr \style .match /'(.+)'/ .1
    href: href $ '.title' @
    name: text $ '.title' @


  {
    type: text '.focus.chl'
    subtype: text '.nameSingle small.grey'
    name: text '.nameSingle a'
    href: href '.nameSingle a'

    cover: src '#bangumiInfo img.cover'
    wiki: mapArray '#infobox>li', parseInfo

    audience: parseAudience $ '#columnSubjectHomeA > div:nth-child(3) > span'
    summary: html '#subject_summary'

    tags: mapArray '.subject_tag_section a', parseTag
    rateAvg: parseFloat text '[property="v:average"]'
    rank: parseInt(text '#columnSubjectInHomeB small.alarm' .slice 1)
    rate: mapArray '.horizontalChart>li', parseRate

    character: mapArray '#browserItemList>li', parseCharacter
    relation: mapArray '.browserCoverMedium>li', parseRelation
  }

