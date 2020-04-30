import { filterSelectors } from "./exclusions.js";

export function interceptEvents(elementSelectors, onIntercepted) {
  const targetSelectors = filterSelectors(elementSelectors);
  const handler = eventHandler(targetSelectors, onIntercepted);
  document.addEventListener("click", handler, { capture: true });
  document.addEventListener("focus", noop, { capture: true });
  document.addEventListener("keydown", handler, { capture: true });
}

function eventHandler(elementSelectors, onIntercepted) {
  return event => {
    let checkElement = event.target;
    let matchedSelector = null;
    while (!matchedSelector && checkElement && checkElement !== document) {
      matchedSelector = matchSelector(elementSelectors, checkElement);
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
