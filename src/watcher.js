const promise = null;
const runAgain = false;

export function watch(handler) {
  const observer = new MutationObserver(handler);
  console.log("Observing", document.body);
  observer.observe(document.body, {
    attributes: true,
    childList: true,
    subtree: true
  });
}

function stop() {
  observer.disconnect();
}

function runIt() {
  console.log("RUNNING IT");
  if (!promise) {
    runAgain = false;
    promise = new Promise((resolve, reject) => {
      setTimeout(resolve, 5000);
    }).then(() => {
      setTimeout(() => {
        promise = null;
        if (runAgain) {
          runIt();
        }
      }, 500);
    });
  } else {
    runAgain = true;
  }
}
