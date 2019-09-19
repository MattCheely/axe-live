import * as Decorator from "./decorator.js";

const FRAME_ID = "axe-live-frame";
const WINDOW_ID = "axe-live-window";
const PANEL_ID = "axe-live-panel";
const FRAME_STYLE = `
position: fixed;
bottom: 0;
left: 10vw;
width: 80vw;
height: 50vh;
z-index: 9999999;
border: none;
`;

const frameContent = `
<div id="${PANEL_ID}"><div>PANEL GOES HERE</div></div>
`;

const frameUrl = `data:text/html,${frameContent}`;

export function getFrame() {
  let frame = document.getElementById(FRAME_ID);
  if (!frame) {
    frame = document.createElement("iframe");
    frame.setAttribute("id", FRAME_ID);
    frame.setAttribute("style", FRAME_STYLE);
    document.body.appendChild(frame);
  }
  return setupWindow(frame.contentWindow);
}

export function getWindow() {
  const win = window.open(
    "",
    WINDOW_ID,
    "menubar=no,toolbar=no,location=no,personalbar=no,status=no"
  );
  return setupWindow(win);
}

function setupWindow(win) {
  win.onbeforeunload = () => {
    Decorator.showFrame();
  };
  return new Promise((resolve, reject) => {
    win.onload = () => {
      resolve(tryDocSetup(win));
    };
    // Kludge for cross-browser onload inconsistencies in about:blank
    setTimeout(() => {
      resolve(tryDocSetup(win));
    }, 60);
  });
}

function tryDocSetup(win) {
  if (!win.axeLiveLoaded) {
    win.document.body.innerHTML = frameContent;
    win.axeLiveLoaded = true;
    return getPanelElement(win.document);
  } else {
    return getPanelElement(win.document);
  }
}

function getPanelElement(document) {
  const wrapper = document.getElementById(PANEL_ID);
  return wrapper && wrapper.children[0];
}
