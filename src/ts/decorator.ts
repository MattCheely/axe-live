import { filterSelectors } from "./exclusions";
import { FRAME_ID, STYLES_ID } from "./identifiers";
import { AppState } from "./panel";

const VIOLATION_HIGHLIGHT_STYLE = `
  {outline: rgba(255, 0, 0, 0.7) dashed 0.3rem !important; outline-offset: -0.15rem}
`;
const VIOLATION_SELECTED_STYLE = `
  {outline-style: solid !important; outline-width: 0.6rem !important; outline-offset: -0.3rem}
`;
const VIOLATION_FOCUSED_STYLE = `
  {outline-color: rgba(114, 195, 250, 0.7) !important; outline-style: solid !important}
`;

const FRAME_STYLE = `
position: fixed;
bottom: 0;
left: 10vw;
width: 80vw;
height: 50vh;
z-index: 9999999;
border: none;
border-radius: 5px 5px 0 0;
`;

const MINIMIZED_FRAME_STYLE = `
position: fixed;
width: 105px;
height: 40px;
bottom: 20px;
right: 20px;
border: none;
border-radius: 5px;
`;

export function minimizeFrame() {
  const styles = ensureStyleSheet();
  (styles.rules[3] as CSSStyleRule).style.cssText = MINIMIZED_FRAME_STYLE;
}

export function expandFrame() {
  const styles = ensureStyleSheet();
  (styles.rules[3] as CSSStyleRule).style.cssText = FRAME_STYLE;
}

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
    
    // rule 3 - iframe
    styles.sheet?.insertRule(`#${FRAME_ID} {${FRAME_STYLE}}`)
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
