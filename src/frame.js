import * as Decorator from "./decorator.js";
import Elm from "./ErrorPanel.elm";

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

export async function updatePanelWindows(
  panels,
  appState,
  onWindowStateChange
) {
  if (appState.popoutOpen && !panels.window) {
    panels.window = await getWindowPanel(appState, panels.frame);
    panels.window.ports.updateExternalState.subscribe(
      onWindowStateChange.bind(null, panels)
    );
  } else if (!appState.popoutOpen && panels.window) {
    panels.window = null;
  }
}

export function getFramePanel(appState) {
  let frame = document.getElementById(FRAME_ID);
  if (!frame) {
    frame = document.createElement("iframe");
    frame.setAttribute("id", FRAME_ID);
    frame.setAttribute("role", "document");
    frame.setAttribute("title", "Axe-Live Violations");
    frame.setAttribute("style", FRAME_STYLE);
    document.body.appendChild(frame);
  }
  return setupWindow(frame.contentWindow, appState);
}

export function getWindowPanel(appState, framedApp) {
  const win = window.open(
    "",
    WINDOW_ID,
    "menubar=no,toolbar=no,location=no,personalbar=no,status=no"
  );

  const closeWindow = win.close.bind(win);

  // Close the external panel when this window unloads
  window.addEventListener("beforeunload", closeWindow);

  // when the window closes, show the frame panel
  win.onbeforeunload = () => {
    window.removeEventListener("beforeunload", closeWindow);
    framedApp.ports.popIn.send();
  };

  return setupWindow(win, appState);
}

function setupWindow(win, appState) {
  return new Promise((resolve, reject) => {
    // Try to set up the panel when the dom is ready
    win.onload = () => {
      resolve(getPanel(win, appState));
    };
    // Kludge for cross-browser onload inconsistencies in about:blank
    setTimeout(() => {
      resolve(getPanel(win, appState));
    }, 60);
  });
}

function getPanel(win, appState) {
  if (!win.panelApp) {
    const target = win.document.createElement("div");
    win.document.body.appendChild(target);

    win.panelApp = Elm.ErrorPanel.init({
      node: target,
      flags: appState
    });
  }
  return win.panelApp;
}
