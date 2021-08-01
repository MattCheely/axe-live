import { filterSelectors } from "./exclusions";
import { log } from "./logger";

let targetSelectors: Array<string> = [];
let listenersCreated = false;

type InterceptHandler = (selector: string) => void;

export function interceptEvents(
  elementSelectors: Array<string>,
  onIntercepted: InterceptHandler
) {
  targetSelectors = filterSelectors(elementSelectors);
  if (!listenersCreated) {
    createListeners(onIntercepted);
  }
}

function createListeners(onIntercepted: InterceptHandler) {
  const handler = eventHandler(onIntercepted);
  log("Watching for events on error elements");
  document.addEventListener("click", handler, { capture: true });
  document.addEventListener("focus", noop, { capture: true });
  document.addEventListener("keydown", handler, { capture: true });
  listenersCreated = true;
}

function eventHandler(onIntercepted: InterceptHandler) {
  return (event: Event) => {
    let checkElement = event.target as HTMLElement | Document | null;
    log("Handling event on", checkElement);
    let matchedSelector = null;

    while (
      !matchedSelector &&
      checkElement !== null &&
      !(checkElement instanceof Document)
    ) {
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

function matchSelector(selectors: Array<string>, element: HTMLElement) {
  return selectors.find(selector => {
    return element.matches(selector);
  });
}

function noop() {}
