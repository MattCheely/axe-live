import { filterSelectors } from "./exclusions.js";
import { log } from "./logger.js";

let targetSelectors = [];
let listenersCreated = false;

export function interceptEvents(elementSelectors, onIntercepted) {
  targetSelectors = filterSelectors(elementSelectors);
  if (!listenersCreated) {
    createListeners(onIntercepted);
  }
}

function createListeners(onIntercepted) {
  const handler = eventHandler(onIntercepted);
  log("Watching for events on error elements");
  document.addEventListener("click", handler, { capture: true });
  document.addEventListener("focus", noop, { capture: true });
  document.addEventListener("keydown", handler, { capture: true });
  listenersCreated = true;
}

function eventHandler(onIntercepted) {
  return event => {
    let checkElement = event.target;
    log("Handling event on", checkElement);
    let matchedSelector = null;
    while (!matchedSelector && checkElement && checkElement !== document) {
      matchedSelector = matchSelector(targetSelectors, checkElement);
      checkElement = checkElement.parentElement;
    }
    if (matchedSelector) {
      event.preventDefault();
      event.stopPropagation();
      onIntercepted(matchedSelector);
    }
  };
}

function matchSelector(selectors, element) {
  return selectors.find(selector => {
    return element.matches(selector);
  });
}

function noop() {}
