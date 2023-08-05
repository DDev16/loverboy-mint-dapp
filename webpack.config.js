const path = require('path');

module.exports = {
  mode: 'development', // Change to 'production' for production build
  entry: './src/index.js', // Entry point of your application
  output: {
    path: path.resolve(__dirname, 'dist'), // Output directory
    filename: 'bundle.js', // Output filename
  },
  resolve: {
    fallback: {
      "stream": require.resolve("stream-browserify"),
      "crypto": require.resolve("crypto-browserify"),
      "http": require.resolve("stream-http"),
      "https": require.resolve("https-browserify"),
      "os": require.resolve("os-browserify/browser"),
      // Remove the "url" fallback from here
    },
  },
  
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader', // If you want to use Babel to transpile your JavaScript code
          options: {
            presets: ['@babel/preset-env'],
          },
        },
      },
    ],
  },
};
