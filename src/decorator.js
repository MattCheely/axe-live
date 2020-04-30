import { filterSelectors } from "./exclusions.js";

const STYLES_ID = "axe-live-styles";
const FRAME_ID = "axe-live-frame";
const VIOLATION_HIGHLIGHT_STYLE = `
  {outline: rgba(255, 0, 0, 0.6) dashed 0.3rem !important; outline-offset: -0.15rem}
`;
const VIOLATION_SELECTED_STYLE = `
  {outline-style: solid !important; outline-width: 0.6rem !important; outline-offset: -0.3rem}
`;
const HIDDEN_FRAME_STYLE = `
  {display: none}
`;

export function updateStyles(appState) {
  const hasProblems = appState.problemElements.length > 0;
  const flaggableProblems = filterSelectors(appState.problemElements);

  if (appState.selectedElement && hasProblems) {
    highlightSelected(appState.selectedElement);
  } else {
    clearSelected();
  }

  if (hasProblems) {
    markViolations(flaggableProblems);
  } else {
    clearViolations();
  }

  if (!appState.popoutOpen && hasProblems) {
    showFrame();
  } else {
    hideFrame();
  }
}

function markViolations(selectors) {
  const jointSelector = selectors.join(",");
  const styles = ensureStyleSheet();
  styles.sheet.rules[0].selectorText = jointSelector;
}

function clearViolations() {
  markViolations([`#${STYLES_ID}`]);
}

function highlightSelected(selector) {
  const styles = ensureStyleSheet();
  styles.sheet.rules[1].selectorText = selector;
}

function clearSelected() {
  highlightSelected(`#${STYLES_ID}`);
}

function hideFrame() {
  const styles = ensureStyleSheet();
  styles.sheet.rules[2].selectorText = `#${FRAME_ID}`;
}

function showFrame() {
  const styles = ensureStyleSheet();
  styles.sheet.rules[2].selectorText = `#${STYLES_ID}`;
}

function ensureStyleSheet() {
  let sheet = document.getElementById(STYLES_ID);
  if (!sheet) {
    sheet = document.head.appendChild(document.createElement("style"));
    sheet.id = STYLES_ID;
    // rule 2 - frameHide - starts hidden
    sheet.sheet.insertRule(`#${FRAME_ID} ${HIDDEN_FRAME_STYLE}`);
    // rule 1 - selection
    sheet.sheet.insertRule(`#${STYLES_ID} ${VIOLATION_SELECTED_STYLE}`);
    // rule 0 - highlight
    sheet.sheet.insertRule(`#${STYLES_ID} ${VIOLATION_HIGHLIGHT_STYLE}`);
  }
  return sheet;
}
