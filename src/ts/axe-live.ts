import * as Axe from "axe-core";
import * as Decorator from "./decorator";
import * as EventBlocker from "./event-blocker";
import * as Watcher from "./watcher";
import { Panel, CheckItems, AppState } from "./panel";
import { log } from "./logger";

export interface Options {
  target: Node,
  watch?: boolean,
  minimized?: boolean  
  axeOptions?: Axe.RunOptions
}

export interface FullOptions {
  target: Node,
  watch: boolean,
  minimized: boolean,
  axeOptions: {}
}

const defaultOptions: FullOptions = {
  target: document,
  watch: true,
  minimized: false,
  axeOptions: {}
}

export async function run(
  options: Options = { target: document, axeOptions: {} },
) {
  const derivedOpts = Object.assign(defaultOptions, options);

  new AxeLiveState(derivedOpts);
}

class AxeLiveState {
  private panel: Panel;
  private options: FullOptions;

  constructor(options: FullOptions) {
    this.options = options;

    this.panel = new Panel({ 
      ...options,
      onCheckElements: this.checkChangedElements.bind(this),
      onExternalStateChange: this.updateDisplayState.bind(this)
    });

    Watcher.watch(options.target, async changedNodes => {
      this.panel.notifyChanges(changedNodes);
    });
  }

  async checkChangedElements(toCheck: CheckItems | null) {
    let elements = null;
    if (toCheck === null) {
      elements = [this.options.target];
    } else {
      elements = toCheck.elements;
      if (toCheck.selectors.length > 0) {
        const selected = document.querySelectorAll(toCheck.selectors.join(","));
        selected.forEach(element => {
          elements.push(element);
        });
      }
    }

    let results = await this.reCheck(elements);
    this.panel.reportViolations(results.violations);
  }

  updateDisplayState(appState: AppState) {
    log(`Highlighiting errors for ${appState.problemElements.length} elements`, appState.problemElements.sort());
    Decorator.updateStyles(appState);
    EventBlocker.interceptEvents(
      appState.problemElements,
      (interceptedSelector: string) => {
        this.panel.elementSelected(interceptedSelector);
      }
    );
  }

  private async reCheck(elements: Array<Node>) {
    let ourOpts: Axe.RunOptions = { ...this.options.axeOptions, reporter: "v1" };
    let result = null;
    if (elements) {
      log(`a11y check starting for ${elements.length} items`, elements);
      // @ts-ignore - I don't like ts-ignore, but the axe docs explicitly say it accepts a NodeList
      // as context, but the type definition doesn't include that
      result = await Axe.run(elements, ourOpts);
    } else {
      log(`a11y check starting`);
      result = await Axe.run(ourOpts);
    }
    log("a11y check completed");
    return result;
  }
}
