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
'node-debugger:attach'
```

## Configuration

The following attributes can be set to control the node-debugger.

* nodePath - path to node.js executable, _default: platform dependent_
* nodeArgs - arguments sent to node.js during launch, _default: ''_
* appArgs - arguments sent to the application during launch, _default: ''_
* debugHost - the machine name or ip-address of the host (only used when attaching to external node processes), _default: '127.0.0.1'_
* debugPort - the port used to communicate to the launched process, _default: 5858_
* env - the process environment variables (if left empty the environment will be inherited), _default: ''_
* scriptMain - the preferred startup file, _default: ''_

An example of a configuration is given below.
```CoffeeScript
"node-debugger":
  nodePath: "C:/program/nodejs/node.exe"
  nodeArgs: "--use-strict --use_inlining"
  appArgs: "--arg1=10 --arg2"
  debugHost: "192.168.0.20"
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

## Attaching to external processes
Start your node application in debug mode using

```Batch
>node --debug=5858 a.js
```

or

```Batch
>node --debug-brk=5858 a.js
```

Make sure that your node-debugger settings for debugHost and debugPort are
matching what you are using. In the case above debugPort should be 5858.

Execute command node-debugger: attach either from the menu or using the command
panel.

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
