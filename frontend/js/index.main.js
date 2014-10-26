var $ = require('jquery');
var _ = require('lodash');

$.get('/rank/index.json').then(function (seasons) {
    $('.ctn-season').html(_.template($('#tpl-season').html(), {seasons: seasons}));
});
