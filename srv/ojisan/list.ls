Promise = require \bluebird
req = require \./request

module.exports = (uri)->
  allItems = []

  fetchPage uri, 1
  .then ({items, maxPage})->
    allItems := allItems.concat items

    Promise.all [2 to maxPage].map ->
      fetchPage uri, it
      .then ({items, maxPage})->
        allItems := allItems.concat items
    .then -> allItems

function fetchPage uri, page
  $ <- (req "https://bgm.tv#{uri}?page=#{page}")then

  maxPage = $('.page_inner a.p')map ->
    parseInt($ @ .attr \href .match /\bpage=(\d+)/ .1)
  .toArray!sort (a,b)-> b - a
  .0

  items = $('#browserItemList>li')map ->
    $item = $ @

    function findText
      $item.find it .text!

    rate = parseFloat(findText 'small.fade') || false
    rateBy = rate && parseInt(findText '.tip_j' .replace /[^\d]*(\d+)[^\d]*/, '$1')
    {
      id: parseInt($item.attr \id .replace /item_/, '')
      cover: $item.find 'img.cover[src]' .attr \src
      name: findText 'a.l'
      nameAlias: findText 'small.grey'
      info: findText '.info'
      rate
      rateBy
    }
  .toArray!

  {items, maxPage}