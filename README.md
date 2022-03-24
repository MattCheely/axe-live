# axe-live


https://user-images.githubusercontent.com/604797/121821320-4fa6e400-cc66-11eb-8362-45f20306e416.mp4


## About

axe-live is a framework-agnostic tool for running accessibility checks against web
applications. It uses Deque Labs' [axe](https://www.deque.com/axe/) library to highlight and disable
elements on the page which have accessibility problems. The goal is to provide something like compiler
errors for accessibilty during the development cycle. This should help problems get addressed right
away rather than waiting on a QA process or user reports.

## Installation

```
npm install axe-live
```

or

```
yarn add axe-live
```

## Setup

When your app is running in development mode, start axe-live:

```javascript
import * as AxeLive from "axe-live";

AxeLive.run();
```

By default, axe-live will watch for changes to your document and try to efficiently re-check when it updates.

You can customize the behavior by passing an options object to `run()`:

```javascript
import * as AxeLive from "axe-live";

AxeLive.run({
  // The node on the page that should be checked, defaults to document
  target: document.getElementById('#app'),
  // Whether or not to re-check on DOM changes, defaults to true
  watch: false,
  // Whether or not to start with a minimal display, defaults to false
  minimized: true,
  // Axe configuration options
  axeOptions: { runOnly: ['wcag2a', 'wcag2aa'] }
});
```

The axe configuration options are passed directly to axe-core's
[`axe.run`](https://www.deque.com/axe/core-documentation/api-documentation/#api-name-axerun)
[options parameter](https://www.deque.com/axe/core-documentation/api-documentation/#options-parameter). 

## Important Notes

Automated checks can ensure you've not made any basic mistakes, but are only part of a robust a11y solution. 
Many of the WCAG guidelines cannot be evaluated automatically, and require a human assesment. It's worthwhile 
to try your app out with a screenreader and think about the usability of the experience for impared users. 

The `axe-core` libarary is _very_ large. You should configure your build to only bundle `axe-live` when 
running in development mode. Otherwise your users will pay an unnecesarily high cost in download times
for your app.

On DOM changes, the watcher is conservative in what it asks Axe to check. Specifically, it only checks changed
elements and elements that were previously in error. This is to make checks faster, but it may result in a rare
miss in the event of a change that renders a previously valid elment invalid. (e.g. a label disappears, making
an previously correct input invalid)

Frequent DOM changes like JS-based animations that update style attributes could lead to checks that run too
frequently. You may ned to turn off automatic re-checking in that situation.