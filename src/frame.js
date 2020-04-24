import * as Decorator from "./decorator.js";
import { Elm } from "./ErrorPanel.elm";

const FRAME_ID = "axe-live-frame";
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

export function getFramePanel(panelState) {
  let frame = document.getElementById(FRAME_ID);
  if (!frame) {
    frame = document.createElement("iframe");
    frame.setAttribute("id", FRAME_ID);
    frame.setAttribute("role", "complementary");
    frame.setAttribute("title", "Axe-Live Violation Panel");
    frame.setAttribute("style", FRAME_STYLE);
    document.body.appendChild(frame);
  }
  return setupWindow(frame.contentWindow, panelState);
}

export function getWindowPanel(panelState) {
  panelState.externalPanel = true;
  const win = window.open(
    "",
    WINDOW_ID,
    "menubar=no,toolbar=no,location=no,personalbar=no,status=no"
  );

  Decorator.hideFrame();
  // when the window closes, show the frame panel
  win.onbeforeunload = () => {
    Decorator.showFrame();
  };

  return setupWindow(win, panelState);
}

function setupWindow(win, panelState) {
  return new Promise((resolve, reject) => {
    // Try to set up the panel when the dom is ready
    win.onload = () => {
      resolve(getPanel(win, panelState));
    };
    // Kludge for cross-browser onload inconsistencies in about:blank
    setTimeout(() => {
      resolve(getPanel(win, panelState));
    }, 60);
  });
}

function getPanel(win, panelState) {
  if (!win.panelApp) {
    const target = win.document.createElement("div");
    win.document.body.appendChild(target);

    win.panelApp = Elm.ErrorPanel.init({
      node: target,
      flags: panelState
    });
  }
  return win.panelApp;
}
