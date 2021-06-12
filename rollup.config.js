import elm from "rollup-plugin-elm";

export default {
  input: "src/axe-live.js",
  output: {
    file: "dist/axe-live.js",
    format: "es"
  },
  plugins: [elm()]
};
