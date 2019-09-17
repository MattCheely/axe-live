import axe from "axe-core";
import { Elm } from "./ErrorPanel.elm";

const STYLES_ID = "axe-live-styles";
const VIOLATION_HIGHLIGHT_STYLE = `
  {outline: rgba(255, 0, 0, 0.6) dashed 0.3rem !important;}
`;
const VIOLATION_SELECTED_STYLE = `
  {outline-style: solid !important; outline-width: 0.6rem !important}
`;

export function run(...axeArgs) {
  axe
    .run(...axeArgs)
    .then(violationsByNode)
    .then(showViolations);
}

function violationsByNode(axeResults) {
  return axeResults.violations.reduce(collectNodes, {});
}

function collectNodes(byNode, violation) {
  violation.nodes.forEach(node => {
    const selector = node.target[0];
    const failureSummary = node.failureSummary;
    byNode[selector] = byNode[selector] || [];
    byNode[selector].push({ ...violation, failureSummary });
  });
  return byNode;
}

function showViolations(violations) {
  const allSelectors = Object.keys(violations);
  const elementSelectors = allSelectors.filter(selector => {
    return !(
      document.body.matches(selector) ||
      document.body.parentElement.matches(selector)
    );
  });

  if (allSelectors.length > 0) {
    const styleSheet = ensureStyleSheet();
    const selector = elementSelectors.join(",");
    highlightViolations(styleSheet, selector);
    const panelApp = renderErrorPanel(violations);
    panelApp.ports.requestSelection.subscribe(toSelect => {
      selectElement(toSelect, styleSheet, panelApp, elementSelectors);
    });
    interceptEvents(elementSelectors, styleSheet, panelApp);
  }
}

function interceptEvents(elementSelectors, styleSheet, panelApp) {
  const handler = eventHandler(elementSelectors, styleSheet, panelApp);
  document.addEventListener("click", handler, { capture: true });
  document.addEventListener("focus", handler, { capture: true });
  document.addEventListener("keydown", handler, { capture: true });
}

function eventHandler(elementSelectors, styleSheet, panelApp) {
  return event => {
    let checkElement = event.target;
    let matchedSelector = null;
    while (
      !matchedSelector &&
      checkElement !== document &&
      checkElement.id !== "axe-live-panel"
    ) {
      matchedSelector = matchSelector(elementSelectors, checkElement);
      checkElement = checkElement.parentElement;
    }
    if (matchedSelector) {
      event.preventDefault();
      event.stopPropagation();
      selectElement(matchedSelector, styleSheet, panelApp, elementSelectors);
    }
  };
}

function selectElement(selector, styleSheet, panelApp, styleSelectors) {
  if (styleSelectors.includes(selector) || !selector) {
    styleSheet.sheet.rules[1].selectorText = selector || STYLES_ID;
  }
  panelApp.ports.selectedElement.send(selector);
}

function matchSelector(selectors, element) {
  return selectors.find(selector => {
    return element.matches(selector);
  });
}

function renderErrorPanel(violations) {
  const panel = ensurePanelElement();
  return Elm.ErrorPanel.init({ node: panel, flags: violations });
}

function ensurePanelElement() {
  const panel = document.createElement("div");
  document.body.appendChild(panel);
  return panel;
}

function highlightViolations(styleSheet, selector) {
  styleSheet.sheet.rules[0].selectorText = selector;
}

function ensureStyleSheet() {
  let sheet = document.getElementById(STYLES_ID);
  if (!sheet) {
    sheet = document.head.appendChild(document.createElement("style"));
    sheet.id = STYLES_ID;
    // rule 1
    sheet.sheet.insertRule(`#axe-live-styles ${VIOLATION_SELECTED_STYLE}`);
    // rule 0
    sheet.sheet.insertRule(`#axe-live-styles ${VIOLATION_HIGHLIGHT_STYLE}`);
  }
  return sheet;
}
