node-debugger package
==============================

> A simple Node.js/io.js debugger for daily use.

## Usage

Open a javascript (.js) file and execute the start-resume command (F5) to launch the debugger.

Debug panels will show up as shown in the image below.

![Screenshot of node-debugger in action](https://raw.githubusercontent.com/kiddkai/atom-node-debugger/master/screenshot.jpg)

The '>' symbol in the gutter marks the current line of execution.

Execute the toggle-breakpoint (F9) command to set a breakpoint. The breakpoint will be displayed in the gutter using a red marker.

Execute start-resume (F5) again to resume debugging or use the step-next (F10), step-in (F11) or step-out (shift-F11) commands.

## Commands

You may access the commands using CMD/Ctrl+p or by using the shortcut key specified within the brackets.

```js
'node-debugger:start-resume' (F5)
'node-debugger:debug-active-file' (ctrl-F5)
'node-debugger:stop' (shift-F5)
'node-debugger:toggle-breakpoint' (F9)
'node-debugger:step-next' (F10)
'node-debugger:step-in' (F11)
'node-debugger:step-out' (shift-F11)
```

## Configuration

The following attributes can be set to control the node-debugger.

* nodePath - path to node.js executable
* nodeArgs - arguments sent to node.js during launch
* appArgs - arguments sent to the application during launch
* debugPort - the port used to communicate to the launched process
* env - the process environment variables (if left empty the environment will be inherited)
* scriptMain - the preferred startup file.

An example of a configuration is given below.
```CoffeeScript
"node-debugger":
  nodePath: "C:/program/nodejs/node.exe"
  nodeArgs: "--use-strict --use_inlining"
  appArgs: "--arg1=10 --arg2"
  debugPort: 5860
  env: "key1=value1;key2=value2;key3=value3"  
  scriptMain: "c:/myproject/main.js"
```

## Debugging projects in atom
When executing the start-resume command the node-debugger will try to figure out
which file that is the main file of the current atom project.
This is the strategy being used:

1. use configured entry point (scriptMain)
1. attempt to read entry point from package.json in the project root folder
1. attempt to start currently open file (ctrl+F5 hot-key)
1. cannot start debugger

## Troubleshooting

Check in the node-debugger package settings that the node path is set correctly.

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
