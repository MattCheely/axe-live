const promise = null;
const runAgain = false;

export function watch(context, handler) {
  const observer = new MutationObserver(handler);
  console.log("axe-live watching", context);
  observer.observe(context, {
    attributes: true,
    childList: true,
    subtree: true
  });
  return observer;
}

function stop(observer) {
  observer.disconnect();
}
