var b = require('./b')
  , result

var c = 100;
var e = {
  foo: 'bar',
  numval1: 10,
  boolval1: true,
  strval1: 'str',
  objval1: {
    numval2: 20,
    boolval2: true,
    strval2: 'str2',
    objval2: {
      numval3: 30,
      boolval3: true,
      strval3: 'str3',
    }
  }
}

var strVal = "a string value";

function localFunc(arg1, arg2) {
  var zz = 10;
  var xx = 20;
  return zz + xx;
}

var f_res = localFunc("strParam", 9991);

console.log('this is a log')
console.error('this is an error')

var d = 10;

b(100, function(err, res) {
  result = res
  console.log('result is: ', result)
});
