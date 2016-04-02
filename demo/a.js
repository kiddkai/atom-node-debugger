var b = require('./b')
  , result

console.log("command line arguments:")
console.log(JSON.stringify(process.argv.slice(2)))

console.log("environment:")
console.log(process.env.key1)

var c = 100;
var e = {
  foo: 'bar',
  numval1: 10,
  boolval1: true,
  strval1: 'str',
  arrVal1: [1,2,3,4],
  objval1: {
    numval2: 20,
    boolval2: true,
    strval2: 'str2',
    arrVal2: [2,3,4,5],
    objval2: {
      numval3: 30,
      boolval3: true,
      strval3: 'str3',
    }
  }
}

var strVal = "a string value";
var arrVal = [1,2,3,4];
var dateVal = new Date(1994, 02, 24, 12, 34);

function localFunc(arg1, arg2) {
  var zz = 10;
  var xx = 20;
  return zz + xx;
}

var f_res = localFunc("strParam", 9991);

console.log('this is a log')
console.error('this is an error')

var d = 10;

var Person = function (firstName, lastName) {
  this.firstName = firstName;
  this.lastName = lastName;
  this.toString = function() {
    return firstName + " " + lastName;
  }
};

var person = new Person('Alice', 'Babs');
console.log(person.toString());

b(100, function(err, res) {
  result = res
  console.log('result is: ', result)
});
