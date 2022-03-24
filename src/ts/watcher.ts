import { log } from "./logger";

export function watch(
  context: Node,
  handler: (mutations: Array<Node>) => void
) {
  const observer = new MutationObserver(mutations => {
    const elements = mutations.map(m =>  m.target);
    log(`Watcher detected DOM mutations on ${elements.length} elements`, elements);
    handler(elements); 
  });
  log("Watching", context);
  observer.observe(context, {
    attributes: true,
    childList: true,
    subtree: true
  });
  return observer;
}
