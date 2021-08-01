/**
 * Helper to add some prefixing to our logging
 */
export function log(...args: Array<any>) {
  console.log("axe-live:", ...args);
}
