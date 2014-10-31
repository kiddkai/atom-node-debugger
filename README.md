node-debugger package [![Build Status](https://travis-ci.org/kiddkai/atom-node-debugger.svg)](https://travis-ci.org/kiddkai/atom-node-debugger) [![Build status](https://ci.appveyor.com/api/projects/status/5b3pwtpbt3k9pdwg)](https://ci.appveyor.com/project/kiddkai/atom-node-debugger)
==============================
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/kiddkai/atom-node-debugger?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is a Node.js debugger for atom. Still working on progress. It still buggy now. I still using my spare time to work on it. Please provide me some feedback to make it better.


![](https://raw.githubusercontent.com/kiddkai/atom-node-debugger/master/screenshot.gif)


Usage
------

### Show panel

```
ctrl + shift + p -> Node Debugger: Toggle
```

### After you start your app


Add a breakpoint
```
ctrl + shift + p -> breakpoint add
```

Please click [here](https://github.com/kiddkai/atom-node-debugger/issues/new)
to provide me more suggestions to improve this debugger, thanks :D

Done
------

1. Main Control
2. Run a node process (.js) files
3. Connect to debugger
4. Show [stderr/stdout] log
5. Jump to source when `break`
6. Breakpoint Control
    + add breakpoint
    + show breakpoint in the gutter
    + List breakpoints
7. Script Control[load]
8. Continue Control[next/step...]
9. Frame Info[argument/locals]
10. Evaluate Expression
11. Show variables



Still working in progress

TODO
------
- Adapting the latest api for adding the mark to Gutter
