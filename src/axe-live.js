import axe from "axe-core";
import * as Decorator from "./decorator.js";
import * as Frame from "./frame.js";
import * as EventBlocker from "./event-blocker.js";

export function run(...axeArgs) {
  axe
    .run(...axeArgs)
    .then(violationsByNode)
    .then(showViolations);
}

window.axeLive = run;

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

async function showViolations(violations) {
  const allSelectors = Object.keys(violations);
  const elementSelectors = allSelectors.filter(notBodyOrHtml);
  const panels = {};

  if (allSelectors.length > 0) {
    Decorator.markViolations(elementSelectors);

    panels.frame = await Frame.getFramePanel({
      selectedElement: null,
      problems: violations
    });
    panels.frame.ports.requestSelection.subscribe(toSelect => {
      selectElement(toSelect, panels, elementSelectors);
    });
    panels.frame.ports.requestPopOut.subscribe(async panelState => {
      panels.window = await Frame.getWindowPanel(panelState);
      panels.window.ports.requestSelection.subscribe(toSelect => {
        selectElement(toSelect, panels, elementSelectors);
      });
      Decorator.hideFrame();
    });

    EventBlocker.interceptEvents(elementSelectors, interceptedSelector => {
      selectElement(interceptedSelector, panels, elementSelectors);
    });
  }
}

function notBodyOrHtml(selector) {
  return !(
    document.body.matches(selector) ||
    document.body.parentElement.matches(selector)
  );
}

function selectElement(selector, panels, selectableElements) {
  if (!selector) {
    Decorator.clearSelected();
  } else if (selectableElements.includes(selector)) {
    Decorator.highlightSelected(selector);
  }
  panels.frame.ports.selectedElement.send(selector);
  if (panels.window) {
    panels.window.ports.selectedElement.send(selector);
  }
}
