var b = require('./b')
  , result

console.log('this is a log')
console.error('this is an error')

b(100, function(err, res) {
  result = res
  console.log('result is: ', result)
});
