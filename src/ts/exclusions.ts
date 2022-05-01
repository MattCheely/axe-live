import { FRAME_ID } from "./identifiers";

export function filterSelectors(selectors: Array<string>) {
  return selectors.filter(selector => {
    return !(
      document.body.matches(selector) ||
      document.body.parentElement?.matches(selector) ||
      document.getElementById(FRAME_ID)?.matches(selector)
    );
  });
}
