const STYLES_ID = "axe-live-styles";
const VIOLATION_HIGHLIGHT_STYLE = `
  {outline: rgba(255, 0, 0, 0.6) dashed 0.3rem !important; outline-offset: -0.15rem}
`;
const VIOLATION_SELECTED_STYLE = `
  {outline-style: solid !important; outline-width: 0.6rem !important; outline-offset: -0.3rem}
`;
const HIDDEN_FRAME_STYLE = `
  {display: none}
`;

export function markViolations(selectors) {
  const jointSelector = selectors.join(",");
  const styles = ensureStyleSheet();
  styles.sheet.rules[0].selectorText = jointSelector;
}

export function highlightSelected(selector) {
  const styles = ensureStyleSheet();
  styles.sheet.rules[1].selectorText = selector;
}

export function clearSelected() {
  highlightSelected(`#${STYLES_ID}`);
}

export function hideFrame() {
  const styles = ensureStyleSheet();
  styles.sheet.rules[2].selectorText = "#axe-live-frame";
}

export function showFrame() {
  const styles = ensureStyleSheet();
  styles.sheet.rules[2].selectorText = STYLES_ID;
}

function ensureStyleSheet() {
  let sheet = document.getElementById(STYLES_ID);
  if (!sheet) {
    sheet = document.head.appendChild(document.createElement("style"));
    sheet.id = STYLES_ID;
    // rule 2 - frameHide
    sheet.sheet.insertRule(`#${STYLES_ID} ${HIDDEN_FRAME_STYLE}`);
    // rule 1 - selection
    sheet.sheet.insertRule(`#${STYLES_ID} ${VIOLATION_SELECTED_STYLE}`);
    // rule 0 - highlight
    sheet.sheet.insertRule(`#${STYLES_ID} ${VIOLATION_HIGHLIGHT_STYLE}`);
  }
  return sheet;
}
