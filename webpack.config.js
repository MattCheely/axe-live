const path = require("path");

module.exports = {
  entry: "./src/axe-live.js",
  output: {
    path: path.resolve(__dirname, "dist"),
    filename: "axe-live.js",
    library: "axeLive"
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: "elm-webpack-loader",
          options: {
            optimize: true
          }
        }
      }
    ]
  }
};
