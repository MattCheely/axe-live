import { log } from "./logger";

export function watch(
  context: Node,
  handler: (mutations: Array<MutationRecord>) => void
) {
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
