node-debugger package
==============================

> A simple Node.js/io.js debugger for daily use.

## Usage

Open a javascript (.js) file and execute the start-resume command (F5) to launch the debugger.

Debug panels will show up as shown in the image below.

![Screenshot of node-debugger in action](/screenshot.jpg)

The '>' symbol in the gutter marks the current line of execution.

Execute the toggle-breakpoint (F9) command to set a breakpoint. The breakpoint will be displayed in the gutter using a red marker.

Execute start-resume (F5) again to resume debugging or use the step-next (F10), step-in (F11) or step-out (shift-F11) commands.

## Commands

You may access the commands using CMD/Ctrl+p or by using the shortcut key specified within the brackets.

```js
'node-debugger:start-resume' (F5)
'node-debugger:stop' (shift-F5)
'node-debugger:toggle-breakpoint' (F9)
'node-debugger:step-next' (F10)
'node-debugger:step-in' (F11)
'node-debugger:step-out' (shift-F11)
```

## Configuration

The following attributes can be set to control the node-debugger.

* nodePath - path to node.js executable
* appArgs - arguments sent to the application during launch
* debugPort - the port used to communicate to the launched process
 
```js
"atom-node-debugger":
  nodePath: "C:/program/nodejs/node.exe"
  appArgs: ""
  debugPort: 5860
```

## Feedback

Please click [here](https://github.com/kiddkai/atom-node-debugger/issues/new)
to provide me more suggestions to improve this debugger, thanks :D

## Todo

```js
CoffeeScript support
Error Handling
```

## Known issues

In `Node.js>=0.12` and `io.js`. The process doesn't stop when your process finished.
So it will have no response from debugger server and will not keep going debugging.
When you face that issue, just use the `x` button to stop the process by yourself.

Issue report is here: https://github.com/nodejs/io.js/issues/1788
