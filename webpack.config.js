var path = require('path');

module.exports = {
    entry: './src/main/js/app.js',
    devtool: 'hidden-source-map',
    cache: true,
	mode: 'development',
    resolve: {
        alias: {
            'stompjs': __dirname + '/node_modules' + '/stompjs/lib/stomp.js',
        }
    },
    output: {
        path: __dirname,
        filename: './src/main/resources/static/built/bundle.js'
    },
	module: {
		rules: [
			{
				test: path.join(__dirname, '.'),
				exclude: /(node_modules)/,
				use: [{
					loader: 'babel-loader',
					options: {
						presets: ["@babel/preset-env", "@babel/preset-react"]
					}
				}]
			}
		]
	}
};