import { filterSelectors } from "./exclusions";
import { FRAME_ID, AppState } from "./panel";

const STYLES_ID = "axe-live-styles";
const VIOLATION_HIGHLIGHT_STYLE = `
  {outline: rgba(255, 0, 0, 0.7) dashed 0.3rem !important; outline-offset: -0.15rem}
`;
const VIOLATION_SELECTED_STYLE = `
  {outline-style: solid !important; outline-width: 0.6rem !important; outline-offset: -0.3rem}
`;
const VIOLATION_FOCUSED_STYLE = `
  {outline-color: rgba(114, 195, 250, 0.7) !important; outline-style: solid !important}
`;

export function updateStyles(appState: AppState) {
  const hasProblems = appState.problemElements.length > 0;
  const flaggableProblems = filterSelectors(appState.problemElements);

  if (appState.selectedElement && hasProblems) {
    highlightSelected(appState.selectedElement);
  } else {
    clearSelected();
  }

  if (appState.focusedElement && hasProblems) {
    highlightFocused(appState.focusedElement);
  } else {
    clearFocused();
  }

  if (hasProblems) {
    markViolations(flaggableProblems);
  } else {
    clearViolations();
  }
}

function markViolations(selectors: Array<string>) {
  const jointSelector = selectors.join(",");
  const styles = ensureStyleSheet();
  (styles.rules[0] as CSSStyleRule).selectorText = jointSelector;
}

function clearViolations() {
  markViolations([`#${STYLES_ID}`]);
}

function highlightSelected(selector: string) {
  const styles = ensureStyleSheet();
  (styles.rules[1] as CSSStyleRule).selectorText = selector;
}

function clearSelected() {
  highlightSelected(`#${STYLES_ID}`);
}

function highlightFocused(selector: string) {
  const styles = ensureStyleSheet();
  (styles.rules[2] as CSSStyleRule).selectorText = selector;
}

function clearFocused() {
  highlightFocused(`#${STYLES_ID}`);
}

function ensureStyleSheet(): CSSStyleSheet {
  let styles = <HTMLStyleElement>document.getElementById(STYLES_ID);
  if (styles === null) {
    styles = <HTMLStyleElement>document.createElement("style");
    document.head.appendChild(styles);
    styles.id = STYLES_ID;

    // rule 2 - focused
    styles.sheet?.insertRule(`#${STYLES_ID} ${VIOLATION_FOCUSED_STYLE}`);
    // rule 1 - selection
    styles.sheet?.insertRule(`#${STYLES_ID} ${VIOLATION_SELECTED_STYLE}`);
    // rule 0 - highlight
    styles.sheet?.insertRule(`#${STYLES_ID} ${VIOLATION_HIGHLIGHT_STYLE}`);
  }

  if (!styles.sheet) {
    throw "Stylesheet CSSOM is missing for some reason!";
  }

  return styles.sheet;
}
