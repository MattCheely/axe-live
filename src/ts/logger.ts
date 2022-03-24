declare global {
  var BUILD_ENV: string;
}

/**
 * Helper to add some prefixing to our logging
 */
export function log(...args: Array<any>) {
  if (BUILD_ENV === "development") {
    console.log("axe-live:", ...args);
  }
}
