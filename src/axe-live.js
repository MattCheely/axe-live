import axe from "axe-core";
import * as Decorator from "./decorator.js";
import * as Frame from "./frame.js";
import * as EventBlocker from "./event-blocker.js";
import * as Watcher from "./watcher.js";
import { log } from "./logger.js";

export async function run(context = document, options = {}) {
  const result = await runAxe(context, options);
  await showViolations(result, options);
}

export async function watch(context = document, options = {}) {
  const result = await runAxe(context, options);
  const panels = await showViolations(result, options);

  Watcher.watch(context, async mutations => {
    panels.frame.ports.notifyChanges.send(mutations);
  });
}

async function reCheck(panels, context, options) {
  if (!options) {
    throw "Whoops! axe-live lost the axe options somewhere!";
  }
  sendAxeStatusToElm(panels, true);
  let result = await runAxe(context, options);
  sendAxeStatusToElm(panels, false);
  return result;
}

async function runAxe(context, options = {}) {
  log(`a11y check starting for ${context.length} items`);
  let ourOpts = { ...options, reporter: "v1" };
  let result = await axe.run(context, ourOpts);
  log("a11y check completed");
  return result;
}

async function showViolations(axeResult, options) {
  const violations = axeResult.violations;
  const panels = {};

  panels.frame = await Frame.getFramePanel({
    selectedElement: null,
    problems: violations,
    axeRunning: false,
    uncheckedChanges: []
  });

  panels.frame.ports.updateExternalState.subscribe(
    updateExternalState.bind(null, panels)
  );

  panels.frame.ports.checkElements.subscribe(
    checkChangedElements.bind(null, panels, options)
  );

  return panels;
}

function updateExternalState(panels, appState) {
  Decorator.updateStyles(appState);
  EventBlocker.interceptEvents(
    appState.problemElements,
    interceptedSelector => {
      selectElement(interceptedSelector, panels);
    }
  );
  Frame.updatePanelWindows(panels, appState, updateExternalState);
}

async function checkChangedElements(panels, options, toCheck) {
  let elements = toCheck.elements || [];
  let selected = document.querySelectorAll(toCheck.selectors.join(","));
  selected.forEach(element => {
    elements.push(element);
  });

  let results = await reCheck(panels, elements, options);
  sendResultsToElm(panels, results);
}

function selectElement(selector, panels) {
  if (panels.window) {
    panels.window.ports.elementSelected.send(selector);
  } else {
    panels.frame.ports.elementSelected.send(selector);
  }
}

function sendResultsToElm(panels, results) {
  if (panels.window) {
    panels.window.ports.violations.send(results.violations);
  }
  panels.frame.ports.violations.send(results.violations);
}

function sendAxeStatusToElm(panels, status) {
  if (panels.window) {
    panels.window.ports.axeRunning.send(status);
  }
  panels.frame.ports.axeRunning.send(status);
}
