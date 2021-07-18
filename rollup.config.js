import elm from "rollup-plugin-elm";
import typescript from "@rollup/plugin-typescript";

export default {
  input: "src/axe-live.ts",
  output: {
    file: "dist/axe-live.js",
    format: "es"
  },
  plugins: [
    elm({
      optimize: true,
      debug: false
    }),
    typescript()
  ]
};
