# axe-live


https://user-images.githubusercontent.com/604797/121821320-4fa6e400-cc66-11eb-8362-45f20306e416.mp4


## About

axe-live is a work-in-progress framework-agnostic tool for running accessibility checks against web
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

When your app is running in development mode, start the watcher to check for errors initially, and
re-check on any changes:

```javascript
import * as AxeLive from "axe-live";

AxeLive.watch();
```

Alternatively to just run checks one:

```javascript
import * as AxeLive from "axe-live";

AxeLive.run();
```

Both the `run` and `watch` functions accept the same parameters as axe-core's
[`axe.run`](https://www.deque.com/axe/core-documentation/api-documentation/#api-name-axerun)

## Misc Notes

The watcher is fairly naive at this point, so it may run slowly or have issues on pages
with frequent rapid changes

You should configure your build to only include `axe-live` when running in development mode.
`axe-core` is a large library that will be expensive for your users to download.
