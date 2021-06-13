import { log } from "./logger.js";

const promise = null;
const runAgain = false;

export function watch(context, handler) {
  const observer = new MutationObserver(mutations => {
    log("Watcher detected DOM mutations");
    handler(mutations);
  });
  log("Watching", context);
  observer.observe(context, {
    attributes: true,
    childList: true,
    subtree: true
  });
  return observer;
}

function stop(observer) {
  observer.disconnect();
}
