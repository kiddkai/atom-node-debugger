node-debugger package
==============================

> A simple Node.js/io.js debugger for daily use.

Usage
------

### Commands - CMD/Ctrl - p

Finished Functionals

```js
'node-debugger:debug-current-file'
'node-debugger:stop'
'node-debugger:add-breakpoint'
```

Todo Functionals

```js
CoffeeScript support
Remove Breakpoint
Error Handling
```


### After you start your app


Add a breakpoint
```
ctrl + shift + p -> breakpoint add
```

Please click [here](https://github.com/kiddkai/atom-node-debugger/issues/new)
to provide me more suggestions to improve this debugger, thanks :D

### Known issues

In `Node.js>=0.12` and `io.js`. The process doesn't stop when your process finished.
So it will have no response from debugger server and will not keep going debugging.
When you face that issue, just use the `x` button to stop the process by yourself.

Issue report is here: https://github.com/nodejs/io.js/issues/1788
