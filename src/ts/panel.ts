import { default as Elm, Flags, App } from "../elm/Main.elm";
import * as Axe from "axe-core";

export const FRAME_ID = "axe-live-frame";
const WINDOW_ID = "axe-live-window";
const FRAME_STYLE = `
position: fixed;
bottom: 0;
left: 10vw;
width: 80vw;
height: 50vh;
z-index: 9999999;
border: none;
`;

export interface CheckItems {
  elements: Array<Element>;
  selectors: Array<string>;
}

export interface AppState {
  selectedElement: string;
  problemElements: Array<string>;
  popoutOpen: boolean;
}

/**
 * Handler for the application requesting a11y checks. If the items to be checked are null, the
 * entire context should be checked.
 */
type CheckHandler = (
  items: CheckItems | null,
  axeOptions: Axe.RunOptions
) => void;

type StateHandler = (data: AppState) => void;

export class Panel {
  private panel?: App;
  private panelDiv: HTMLElement = document.createElement("div");
  private onCheckElements: CheckHandler;
  private onExternalStateChange: StateHandler;
  private axeOptions: Axe.RunOptions;

  /**
   * Creates a new panel
   */
  constructor(
    axeOptions: Axe.RunOptions,
    options: {
      onCheckElements: CheckHandler;
      onExternalStateChange: StateHandler;
    }
  ) {
    this.onCheckElements = options.onCheckElements;
    this.onExternalStateChange = options.onExternalStateChange;
    this.axeOptions = axeOptions;

    this.createFramePanel().then(panel => {
      this.panel = panel;
      this.setUpPanelSubscriptions(panel);
    });
  }

  /**
   * Passes an error report from Axe into the panel for display & processing
   */
  reportViolations(violations: unknown): void {
    this.panel?.ports.violations.send(violations);
  }

  /**
   * Indicates that an element has been selected via interaction in the target page.
   */
  elementSelected(selector: string): void {
    this.panel?.ports.elementSelected.send(selector);
  }

  /**
   * Notifies the panel that DOM changes have occured
   */
  notifyChanges(changes: unknown): void {
    this.panel?.ports.notifyChanges.send(changes);
  }

  /**
   * Lets the panel know that axe is currently running
   */
  axeRunning(isRunning: boolean): void {
    this.panel?.ports.axeRunning.send(isRunning);
  }

  /**
   * Initializes the panel in an embedded iframe
   */
  private async createFramePanel(): Promise<App> {
    let win = getFrameWindow();
    await waitForLoad(win);

    let app = Elm.Main.init({
      node: this.panelDiv
    });

    this.openFramePanel();

    return app;
  }

  /**
   * Opens the embedded frame, and moves the panel into it
   */
  private openFramePanel() {
    let win = getFrameWindow();
    win.document.body.appendChild(win.document.adoptNode(this.panelDiv));
    win.frameElement?.removeAttribute("hidden");
  }

  private closeFramePanel() {
    let win = getFrameWindow();
    // Don't actually remove the frame, that causes all kinds of
    // difficulty brining it back later.
    win.frameElement?.setAttribute("hidden", "");
  }

  /**
   * Sets up all the subscriptions for the panel.
   * Takes the panel as an argument to guarantee we only run it after the
   * panel has been created.
   */
  private setUpPanelSubscriptions(panel: App) {
    panel.ports.popOut.subscribe(() => {
      this.openExternalPanel();
    });

    panel.ports.checkElements.subscribe((toCheck: any) => {
      this.onCheckElements(toCheck, this.axeOptions);
    });
    panel.ports.updateExternalState.subscribe((externalState: any) => {
      this.onExternalStateChange(externalState);
    });
  }

  /**
   * Opens an external window and moves the panel into it
   */
  private async openExternalPanel(): Promise<void> {
    this.closeFramePanel();
    const externalWindow = window.open(
      "",
      WINDOW_ID,
      "menubar=no,toolbar=no,location=no,personalbar=no,status=no"
    );

    if (externalWindow === null) {
      throw "I couldn't open a popout window";
    }

    // Close the external axe-live window when the current window closes
    const closeWindow = externalWindow.close.bind(externalWindow);
    window.addEventListener("beforeunload", closeWindow);

    // when the external panel closes...
    externalWindow.onbeforeunload = () => {
      // Remove the event listener added previously
      window.removeEventListener("beforeunload", closeWindow);
      // Open the frame panel
      this.openFramePanel();
    };

    // Actually finish setting up the panel once the new window finishes loading
    await waitForLoad(externalWindow);
    const externalDocument = externalWindow.document;

    // Kludge to hide the popout interaction in the external window
    const styles = externalDocument.createElement("style");
    styles.innerHTML = "#popout-button { display: none; }";
    externalDocument.head.appendChild(styles);

    externalDocument.body.appendChild(
      externalDocument.adoptNode(this.panelDiv)
    );
  }
}

/**
 * Waits for a window to load. Without this, content added to a new blank window
 * or frame might be destroyed if the browser is still loading the empty page.
 */
function waitForLoad(win: Window): Promise<void> {
  return new Promise((resolve, _reject) => {
    // Try to set up the panel when the dom is ready
    win.onload = () => {
      resolve();
    };
    // Kludge for cross-browser onload inconsistencies in about:blank
    setTimeout(() => {
      resolve();
    }, 60);
  });
}

/**
 * Gets the window associated with the embedded axe-live iframe, creating it if
 * it does not exist.
 */
function getFrameWindow(): Window {
  let frame = <HTMLIFrameElement>document.getElementById(FRAME_ID);
  if (frame === null) {
    frame = <HTMLIFrameElement>document.createElement("iframe");
    frame.setAttribute("id", FRAME_ID);
    frame.setAttribute("role", "document");
    frame.setAttribute("title", "Axe-Live Violations");
    frame.setAttribute("style", FRAME_STYLE);
    document.body.appendChild(frame);
  }

  // Seems like overkill, but makes TS happy and it's better than a cast
  if (frame.contentWindow === null) {
    throw "I was unable to create an iframe to host the axe-live panel";
  }

  return frame.contentWindow;
}
