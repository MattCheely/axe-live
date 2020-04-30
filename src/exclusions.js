import { FRAME_ID } from "./frame.js";

export function filterSelectors(selectors) {
  return selectors.filter(selector => {
    return !(
      document.body.matches(selector) ||
      document.body.parentElement.matches(selector) ||
      document.getElementById(FRAME_ID).matches(selector)
    );
  });
}
