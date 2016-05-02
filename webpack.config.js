var webpack = require('webpack');
var CommonsChunkPlugin = require('webpack/lib/optimize/CommonsChunkPlugin');
var glob = require('glob');

function getEntry() {
    var entry = {};
    glob.sync(__dirname + '/frontend/js/*.main.js').forEach(function (name) {
        var n = name.match(/([^/]+?)\.main\.js/)[1];

        entry[n] = './js/' + n + '.main.js';
    });

    return entry;
}

module.exports = {
    refreshEntry: function () {
        this.entry = getEntry();
    },
    context: __dirname + '/frontend/',
    entry: getEntry(),
    resolve: {
        modulesDirectories: [
            'node_modules',
            'lib'
        ]
    },
    plugins: [
//        new CommonsChunkPlugin('common.min.js', 5),
        // new webpack.optimize.UglifyJsPlugin()
    ],
    devtool: 'source-map',
    output: {
        path: __dirname + '/public/js',
        filename: '[name].min.js',
        sourceMapFilename: '[file].map'
    }
};
