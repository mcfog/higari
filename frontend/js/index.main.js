$.get('//rank-data.mcfog.wang/index-all.json?' + (localStorage.timestamp || parseInt(Date.now() / 7200000))).then(function (seasons) {
    $('.ctn-season').html(_.template($('#tpl-season').html())(seasons));
});
