function optionChange(t){function e(t){var e=$("[name="+t+"]",n);a?e.prop("checked",!!option[t]):option[t]=!!e.prop("checked")}var n=$(".control-panel"),a=!0===t;!function(t){var e=$("[name="+t+"]",n);a?e.val(option[t]):option[t]=e.val()}("order"),e("hentai"),e("rateBy"),e("small"),a||(localStorage.option=JSON.stringify(option)),a?renderNow():render()}function filter(t){return _(t).filter(function(t){return!option.hentai^hentai(t)}).filter(function(t){return!option.rateBy||t.rateBy}).sortBy(function(t,e){if("default"===option.order)return-power(t);if("fav"===option.order){var n=0;return _.each(t.detail.audience,function(t){n+=t}),-n}if("rate"===option.order){var a=t.rate;return t.detail.rank&&(a-=1e-7*t.detail.rank),-a}return"rater"===option.order?-(t.rateBy||0):e}).value()}function hentai(t){return"hentai"in t.detail?t.detail.hentai:t.detail.tags.filter(function(t){return-1!==_.indexOf(["里番","肉番","H","18禁"],t.text)}).length>0}function goodAudience(t){function e(t,e){a+=(n[t]||0)*e}var n=t.detail.audience,a=0;return e("collections",1.5),e("doings",.8),e("wishes",.5),e("dropped",-4),e("on_hold",-2),a}function power(t){return Math.pow(t.rate/10,.75)*goodAudience(t)}function renderNow(){var t=$(".ctn-list");t.empty().fadeTo(1,.01,function(){var e=$("#tpl-list").html();filter(list).forEach(function(n,a){var r=$('<div class="row lazyload">').html(_.template(e)({item:n,option:option})).data("row-item",n);t.append(r)}),t.fadeTo("normal",1)})}function lazyload(t){var e=$(t.target),n=e.data("row-item"),a=_.uniqueId();$(".audience-chart",e).attr("id","_ac_"+a),renderDonut(n,"_ac_"+a),$(".gauge-chart",e).attr("id","_g_"+a),renderGauge(n,"_g_"+a),$(".rate-chart",e).attr("id","_r_"+a),renderRate(n,"_r_"+a),renderTags(n,$(".tags",e))}function renderDonut(t,e){function n(e,n){var o=t.detail.audience[n]||0;r+=o,a.push([e,o])}var a=[],r=0;return n("想看","wishes"),n("在看","doings"),n("看过","collections"),n("搁置","on_hold"),n("抛弃","dropped"),c3.generate({size:{height:option.small?200:300},data:{columns:a,order:null,type:"donut"},donut:{title:option.small?"":r+"人收藏"},bindto:"#"+e})}function renderRate(t,e){var n=[],a=[];return t.detail.rate.forEach(function(t){a.push(t.rate),n.push(t.count)}),n.unshift("rate"),c3.generate({size:{height:240},data:{columns:[n],order:null,type:option.small?"bar":"area-spline"},axis:{x:{type:"category",categories:a}},bindto:"#"+e})}function renderGauge(t,e){return c3.generate({size:{height:150},data:{columns:[["评分",t.rate||0]],type:"gauge"},gauge:{min:5,max:9,label:{format:function(e,n){return t.rateBy?e.toFixed(1)+"*"+t.rateBy+"人":"评分暂缺"}}},color:{pattern:["#AAAAAA","#2ECC40","#FF851B","#FF4136"],threshold:{values:[6,7.5,9]}},bindto:"#"+e})}function renderTags(t,e){function n(){var t=parseInt(l()*a.length);return t==n.last&&(t=parseInt(l()*a.length)),t==n.last?n.last=t=parseInt(l()*a.length):n.last=t}var a="label-primary label-info label-success label-warning label-danger".split(/ /g),r=0,o=(new Date).getFullYear(),i=t.detail.tags.filter(function(t){return-1===t.text.indexOf(o)});i.forEach(function(t){r=Math.max(r,t.count)});var l=Math.seedrandom(t.id,{global:!1});i.forEach(function(t){var o=$("<a>"),i=Math.pow(t.count/r,.5);o.attr("title","* "+t.count).addClass("label").addClass(a[n()]).css("opacity",.4+.8*i).css("transform","scale("+Math.min(1,.8+.3*i)+")").text(t.text),e.append(o).append(" ")})}riot.route(function(t){var e=t.slice(1).split(/\//g);routes[e[0]]?routes[e[0]].apply(null,e.slice(1)):location="/"});var list=[],option=JSON.parse(localStorage.option||'{"order":"default"}'),render=_.throttle(renderNow,150,{leading:!1}),routes={season:function(t){t.match(/\d{4}-\d{1,2}/)?$.get("//rank-data.mcfog.wang/"+t+".json?"+(localStorage.timestamp||parseInt(Date.now()/72e5))).then(function(t){list=t,optionChange(!0)}):location="/"}};$(document).on("lazybeforeunveil",".ctn-list>.row",lazyload).on("change",".control-panel *",optionChange);