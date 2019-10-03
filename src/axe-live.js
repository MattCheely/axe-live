import axe from "axe-core";
import * as Decorator from "./decorator.js";
import * as Frame from "./frame.js";
import * as EventBlocker from "./event-blocker.js";
import * as Watcher from "./watcher.js";

export function run(...axeArgs) {
  axe.run(...axeArgs).then(showViolations);
}

export function watch(...axeArgs) {
  Watcher.watch((...args) => {
    console.log("CHANGED", args);
  });
}

async function showViolations(axeResult) {
  const violations = axeResult.violations;
  const panels = {};

  if (violations.length > 0) {
    panels.frame = await Frame.getFramePanel({
      selectedElement: null,
      problems: violations
    });

    panels.frame.ports.flagErrorElements.subscribe(selectors => {
      const elementSelectors = filterSelectors(selectors);
      Decorator.markViolations(elementSelectors);
      EventBlocker.interceptEvents(elementSelectors, interceptedSelector => {
        selectElement(interceptedSelector, panels);
      });
    });

    panels.frame.ports.selectElement.subscribe(toSelect => {
      highlightSelection(toSelect);
    });

    panels.frame.ports.requestPopOut.subscribe(async panelState => {
      panels.window = await Frame.getWindowPanel(panelState);
      panels.window.ports.selectElement.subscribe(toSelect => {
        highlightSelection(toSelect);
        panels.frame.ports.elementSelected.send(toSelect);
      });
    });
  }
}

function highlightSelection(toSelect) {
  if (toSelect) {
    Decorator.highlightSelected(toSelect);
  } else {
    Decorator.clearSelected();
  }
}

function filterSelectors(selectors) {
  return selectors.filter(notBodyOrHtml);
}

function notBodyOrHtml(selector) {
  return !(
    document.body.matches(selector) ||
    document.body.parentElement.matches(selector)
  );
}

function selectElement(selector, panels) {
  highlightSelection(selector);
  if (panels.window) {
    panels.window.ports.elementSelected.send(selector);
  } else {
    panels.frame.ports.elementSelected.send(selector);
  }
}
