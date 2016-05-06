// ref: https://github.com/Raynos/mercury/blob/master/examples/lib/focus-hook.js
//var document = require('global/document');
//var nextTick = require('next-tick');

module.exports = MutableFocusHook;

function MutableFocusHook() {
    if (!(this instanceof MutableFocusHook)) {
        return new MutableFocusHook();
    }
}

MutableFocusHook.prototype.hook = function hook(node, property) {
    process.nextTick(function onTick() {
        if (document.activeElement !== node) {
            node.focus();
        }
    });
};
