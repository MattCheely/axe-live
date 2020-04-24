import axe from "axe-core";
import * as Decorator from "./decorator.js";
import * as Frame from "./frame.js";
import * as EventBlocker from "./event-blocker.js";
import * as Watcher from "./watcher.js";

export async function run(context = document, options) {
  const result = await runAxe(context, options);
  await showViolations(result);
}

export async function watch(context = document, options) {
  const result = await runAxe(context, options);
  const panels = await showViolations(result);

  Watcher.watch(context, async mutations => {
    panels.frame.ports.notifyChanges.send(mutations);
  });
}

async function runAxe(context, options = {}) {
  //TODO: try "no-passes" reporter
  let ourOpts = { ...options, reporter: "v1" };
  return await axe.run(context, ourOpts);
}

async function showViolations(axeResult) {
  const violations = axeResult.violations;
  const panels = {};

  panels.frame = await Frame.getFramePanel({
    selectedElement: null,
    problems: violations
  });

  panels.frame.ports.flagErrorElements.subscribe(selectors => {
    if (selectors.length === 0) {
      closePanel(panels);
    } else {
      openPanel(panels);
    }
    const elementSelectors = filterSelectors(selectors);
    Decorator.markViolations(elementSelectors);
    EventBlocker.interceptEvents(elementSelectors, interceptedSelector => {
      selectElement(interceptedSelector, panels);
    });
  });

  panels.frame.ports.selectElement.subscribe(toSelect => {
    highlightSelection(toSelect);
  });

  panels.frame.ports.checkElements.subscribe(async toCheck => {
    let elements = toCheck.elements || [];
    let selected = document.querySelectorAll(toCheck.selectors.join(","));
    selected.forEach(element => {
      elements.push(element);
    });

    let results = await runAxe(elements);
    showResults(panels, results);
  });

  panels.frame.ports.requestPopOut.subscribe(async panelState => {
    panels.window = await Frame.getWindowPanel(panelState);
    panels.window.ports.selectElement.subscribe(toSelect => {
      highlightSelection(toSelect);
      panels.frame.ports.elementSelected.send(toSelect);
    });
  });

  return panels;
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

function showResults(panels, results) {
  if (panels.window) {
    panels.window.ports.violations.send(results.violations);
  }
  panels.frame.ports.violations.send(results.violations);
}

function closePanel(panels) {
  if (!panels.window) {
    Decorator.hideFrame();
  }
}

function openPanel(panels) {
  if (!panels.window) {
    Decorator.showFrame();
  }
}
