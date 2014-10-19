module.exports = function(val, fn) {
  setTimeout(function() {
    debugger
    fn(null, val + 100)
  }, 1000)
}
