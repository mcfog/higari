var $ = require('jquery');
var _ = require('lodash');

$.get('http://7xqy5q.com1.z0.glb.clouddn.com/index.json').then(function (seasons) {
    $('.ctn-season').html(_.template($('#tpl-season').html(), {seasons: seasons}));
});
