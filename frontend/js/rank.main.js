var $ = require('jquery');
var _ = require('lodash');
var riot = require('riotjs');
var d3 = require('d3');
var c3 = require('c3/c3');

require('lazysizes');

riot.route(function (hash) {
    var parts = hash.slice(1).split(/\//g);
    if (!routes[parts[0]]) {
        location = '/';
        return;
    }

    routes[parts[0]].apply(null, parts.slice(1));
});

var list = [];
var option = JSON.parse(localStorage.option || '{"order":"default"}');
var render = _.throttle(renderNow, 150, {
    leading: false
});

var routes = {
    season: function (season) {
        if (!season.match(/\d{4}-\d{1,2}/)) {
            location = '/';
            return;
        }

        $.get('http://7xqy5q.com1.z0.glb.clouddn.com/' + season + '.json?' + (localStorage.timestamp || parseInt(Date.now() / 7200000)))
            .then(function (o) {
                list = o;
                optionChange(true);
            });
    }
};

$(document)
    .on('lazybeforeunveil', '.ctn-list>.row', lazyload)
    .on('change', '.control-panel *', optionChange);

function optionChange(event) {
    var $cp = $('.control-panel');
    var init = event === true;

    input('order');
    checkbox('hentai');
    checkbox('rateBy');
    checkbox('small');

    if(!init) {
        localStorage.option = JSON.stringify(option);
    }

    init ? renderNow() : render();

    function checkbox(name) {
        var $control = $('[name=' + name + ']', $cp);
        if(init) {
            $control.prop('checked', !!option[name]);
            return;
        }

        option[name] = !!$control.prop('checked');
    }

    function input(name) {
        var $control = $('[name=' + name + ']', $cp);
        if(init) {
            $control.val(option[name]);
            return;
        }

        option[name] = $control.val();
    }

}

function filter(list) {
    return _(list)
        .filter(function (item) {
            return !option.hentai ^ hentai(item);
        })
        .filter(function (item) {
            return !option.rateBy || item.rateBy;
        })
        .sortBy(function (item, idx) {
            if (option.order === 'default') {
                return -power(item);
            } else if (option.order === 'fav') {
                var sum = 0;
                _.each(item.detail.audience, function (count) {
                    sum += count;
                });

                return -sum;
            } else if (option.order === 'rate') {
                var rate = item.rate;
                if (item.detail.rank) {
                    rate -= 0.0000001 * item.detail.rank;
                }

                return -rate;
            } else if (option.order === 'rater') {
                return -(item.rateBy || 0);
            }

            return idx;
        })
        .value();
}

function hentai(item) {
    return item.detail.tags.filter(function (tag) {
        return -1 !== _.indexOf(['里番', '肉番', 'H', '18禁'], tag.text);
    }).length > 0;
}

function goodAudience(item) {
    var audience = item.detail.audience;
    var rate = 0;
    take('collections', 1.5);
    take('doings', 0.8);
    take('wishes', 0.5);
    take('dropped', -4);
    take('on_hold', -2);

    return rate;

    function take(key, weight) {
        rate += (audience[key] || 0) * weight;
    }
}

function power(item) {
    return Math.pow(item.rate / 10, 0.75) * goodAudience(item);
}

function renderNow() {
    var $list = $('.ctn-list');
    $list.empty().fadeTo(1, 0.01, function () {
        var tpl = $('#tpl-list').html();
        filter(list).forEach(function (item, idx) {
            var $row = $('<div class="row lazyload">').html(
                _.template(tpl, {
                    item: item,
                    option: option
                })
            ).data('row-item', item);
            $list.append($row);
        });

        $list.fadeTo('normal', 1);
    });
}

function lazyload(event) {
    var $row = $(event.target);
    var item = $row.data('row-item');
    var id = _.uniqueId();
    $('.audience-chart', $row).attr('id', '_ac_' + id);
    renderDonut(item, '_ac_' + id);

    $('.gauge-chart', $row).attr('id', '_g_' + id);
    renderGauge(item, '_g_' + id);

    $('.rate-chart', $row).attr('id', '_r_' + id);
    renderRate(item, '_r_' + id);

    renderTags(item, $('.tags', $row));
}
function renderDonut(item, id) {
    var columns = [];
    var sum = 0;

    pushCol('想看', 'wishes');
    pushCol('在看', 'doings');
    pushCol('看过', 'collections');
    pushCol('搁置', 'on_hold');
    pushCol('抛弃', 'dropped');

    function pushCol(name, key) {
        var count = item.detail.audience[key] || 0;
        sum += count;
        columns.push([name, count]);
    }

    return c3.generate({
        size: {
            height: option.small ? 200 : 300
        },
        data: {
            columns: columns,
            order: null,
            type: 'donut'
        },
        donut: {
            title: option.small ? '' : sum + '人收藏'
        },
        bindto: '#' + id
    });
}

function renderRate(item, id) {

    var column = [];
    var x = [];

    item.detail.rate.forEach(function (item) {
        x.push(item.rate);
        column.push(item.count);
    });

    column.unshift('rate');

    return c3.generate({
        size: {
            height: 240
        },
        data: {
            columns: [column],
            order: null,
            type: option.small ? 'bar' : 'area-spline'
        },
        axis: {
            x: {
                type: 'category',
                categories: x
            }
        },
        bindto: '#' + id
    });
}

function renderGauge(item, id) {
    return c3.generate({
        size: {
            height: 150
        },
        data: {
            columns: [
                ['评分', item.rate || 0]
            ],
            type: 'gauge'
        },
        gauge: {
            min: 5,
            max: 9,
            label: {
                format: function (value, ratio) {
                    if (!item.rateBy) {
                        return '评分暂缺';
                    }
                    return value.toFixed(1) + '*' + item.rateBy + '人';
                }
            }
        },
        color: {
            pattern: ['#AAAAAA', '#2ECC40', '#FF851B', '#FF4136'],
            threshold: {
                values: [6.0, 7.5, 9.0]
            }
        },
        bindto: '#' + id
    });
}

function renderTags(item, $tags) {
    var cssClass = 'label-primary label-info label-success label-warning label-danger'.split(/ /g);
    var max = 0;
    var year = new Date().getFullYear();
    item.detail.tags.forEach(function (tag) {
        max = Math.max(max, tag.count);
    });
    var rand = require('seedrandom')(item.id);

    item.detail.tags
//        .sort(function (a, b) {
//            return b.count - a.count;
//        })
        .filter(function (tag) {
            return -1 === tag.text.indexOf(year);
        })
        .forEach(function (tag) {
            var $tag = $('<a>');
            var weight = Math.pow(tag.count / max, 0.5);
            $tag
                .addClass('label')
                .addClass(cssClass[parseInt(rand() * cssClass.length)])
                .css('opacity', Math.max(0.1, weight))
                .css('transform', 'scale('+(Math.min(1, 0.8 + 0.3 * weight))+')')
                .text(tag.text);

            $tags.append($tag).append(' ');
        });
}
