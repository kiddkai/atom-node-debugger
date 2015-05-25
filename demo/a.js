var b = require('./b')
  , result

var c = 100;
var e = {
  foo: 'bar'
}

console.log('this is a log')
console.error('this is an error')

var d = 10;

b(100, function(err, res) {
  result = res
  console.log('result is: ', result)
});
