import elm from "rollup-plugin-elm";
import typescript from "@rollup/plugin-typescript";
import { nodeResolve } from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";
import replace from "@rollup/plugin-replace";

const env = process.env.ROLLUP_WATCH === "true" ? "development" : "production";

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
    commonjs(),
    replace({
      include: "src/ts/logger.ts",
      BUILD_ENV: JSON.stringify(env)
    })
  ]
};
