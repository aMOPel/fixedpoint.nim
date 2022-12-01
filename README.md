# fixedpoint.nim

This is a library for [Fixed-point](https://en.wikipedia.org/wiki/Fixed-point_arithmetic) numbers in [Nim](https://nim-lang.org/).

__Disclaimer:__ This library is not very optimised. It doesn't work on a bit level.

### Why not floats?

This lib can be handy, if you're working with numbers that you will convert to strings
and/or numbers that are supposed to have a specific amount of digits after the decimal point.
With floats problems can arise in this case, because you will usually round the float
to comply to your digit count. 
The problems arise, if you use operations with your floats and round them all after the operations.
Eg:
```nim
let 
  a = 0.566
  b = 0.466
  c = a + b
echo &"{a.round(2)} + {b.round(2)} = {c.round(2)}"
# 0.57 + 0.47 = 1.03
# doesn't add up
# instead you would need to round your floats everywhere before you operate on them
# (in fact that is more or less what this lib is doing)
```

### Usage

```nim
import fixedpoint

# constructors
assert `$`($$3) == "0.000"
assert `$`(1000$$2) == "10.00"

assert `$`($$10.0) == "10.0"
assert `$`(10.0$$2) == "10.00"
assert `$`($$"10.00") == "10.00"

# you can also use fixedpoint() instead of the $$ operator
assert $fixedPoint(1000,2) == "10.00"

# operators
assert `$`(100$$2 + 1234$$1)=="124.40"
assert `$`(100$$2 - 1234$$1)=="-122.40"
assert `$`(100$$2 * 1234$$1)=="123.40"
assert `$`(100$$2 / 1234$$1)=="0.01" # float value is 0.0081037277

# you can decide if you want to keep more or less decimal places 
# for every operation individually 
assert `$`(`+`(100$$2, 1234$$1, dsKeepLess)=="124.4"

# or set `defaultDecimalStrategy`
# default value is `dsKeepMore`
defaultDecimalStrategy = dsKeepLess
assert `$`(100$$2 + 1234$$1)=="124.4"

# there are also 
# += -= *= /=

# comparisons
assert 100$$2 == $$"1.00"
assert 100$$2 < 1234$$1
assert 100000$$2 > 1234$$1
# there are also 
# == >= <=

# convert back to float or int
assert toFloat($$10.0) == 10.0
assert toInt($$10.6) == 11

# change decimalPlaces after construction:
var a = $$10.1 
var b = $$10.157
a.setDecimalPlaces(3)
b.setDecimalPlaces(2)
assert $a == "10.100"
assert $b == "10.16"
```
