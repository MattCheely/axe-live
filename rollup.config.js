import elm from "rollup-plugin-elm";
import typescript from "@rollup/plugin-typescript";
import { nodeResolve } from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";

export default {
  input: "src/ts/axe-live.ts",
  output: {
    file: "dist/axe-live.js",
    format: "es"
  },
  plugins: [
    elm({
      optimize: true,
      debug: false
    }),
    typescript(),
    nodeResolve(),
    commonjs()
  ]
};
