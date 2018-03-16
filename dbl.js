const fs = require('fs')
function bytesToSize(bytes) {
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  if (bytes == 0) return '0 Byte';
  const i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
  return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
};

const async_hooks = require('async_hooks');

// Return the ID of the current execution context.
const eid = async_hooks.executionAsyncId();

// Return the ID of the handle responsible for triggering the callback of the
// current execution scope to call.
const tid = async_hooks.triggerAsyncId();

// Create a new AsyncHook instance. All of these callbacks are optional.
const asyncHook =	async_hooks.createHook({ init, before, after, destroy, promiseResolve });

// Allow callbacks of this AsyncHook instance to call. This is not an implicit
// action after running the constructor, and must be explicitly run to begin
// executing callbacks.
asyncHook.enable();

// Disable listening for new asynchronous events.
// asyncHook.disable();

//
// The following are the callbacks that can be passed to createHook().
//

// init is called during object construction. The resource may not have
// completed construction when this callback runs, therefore all fields of the
// resource referenced by "asyncId" may not have been populated.
function init(asyncId, type, triggerAsyncId, resource) { }

// before is called just before the resource's callback is called. It can be
// called 0-N times for handles (e.g. TCPWrap), and will be called exactly 1
// time for requests (e.g. FSReqWrap).
function before(asyncId) { }

// after is called just after the resource's callback has finished.
function after(asyncId) { }

// destroy is called when an AsyncWrap instance is destroyed.
function destroy(asyncId) { }

// promiseResolve is called only for promise resources, when the
// `resolve` function passed to the `Promise` constructor is invoked
// (either directly or through other means of resolving a promise).
function promiseResolve(asyncId) { }

setTimeout(() => {console.log('Timeout 0ms')}, 0)
setImmediate(() => console.log("setImmediate", bytesToSize(process.memoryUsage().heapUsed)))
process.nextTick(() => console.log("nextTick", bytesToSize(process.memoryUsage().heapUsed)))
Promise.resolve("Promise resolve").then((val) => {console.log(val)})

var f = fs.readFile('./text.json', (e) => {if (e) console.error(e); console.log('./text.json') })

console.log("eid", eid)
console.log("tid", tid)
console.log("asyncHook", asyncHook)


function clone(src, obj) {
	if (typeof(src) !== 'object' || typeof(obj) !== 'object') throw new Error("source and clone must be Objects")
	Object.entries(src).forEach(([k, v]) => { 
			obj[k] = v
	});
}

var obj = {
	a: 1,
	b: 2,
	c: function() {},
	d: [1,2]
}

var aze = obj;
var qsd = {}
clone(obj, qsd)

console.log(aze)
console.log(qsd)
console.log(obj)

var map = new Map(Object.entries(obj));
var set = new Set(Object.entries(obj));
qsd.a = 3
map.set("E", {a: "b"})
map.set("FUN", function() {})

console.log(aze)
console.log(qsd)
console.log(obj)
console.log(map)
console.log(set)

console.log(map.get('a'))
console.log(Map.toString())

var aqw = {}

if (aqw["a"] instanceof Array) {
	console.log(aqw["a"])
} else {
	console.log("à pas!")
}