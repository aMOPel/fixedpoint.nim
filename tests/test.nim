import fixedpoint
# import print

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
assert `$`(100$$2 / 1234$$1)=="0.01" # real value is 0.0081037277

# you can decide if you want to keep more or less decimal places 
# for every operation individually or set 
# `defaultDecimalStrategy`
# default value is `dsKeepMore`

defaultDecimalStrategy = dsKeepLess
assert `$`(100$$2 + 1234$$1)=="124.4"

defaultDecimalStrategy = dsKeepMore

# there are also 
# += -= *= /=

# comparisons
assert 100$$2 == $$"1.00"
assert 100$$2 < 1234$$1
assert 100000$$2 > 1234$$1
# there are also 
# == >= <=

# convert back to float
assert toFloat($$10.0) == 10.0
assert toInt($$10.6) == 11

# change decimalPlaces after construction:
var a = $$10.1 
var b = $$10.157
a.setDecimalPlaces(3)
b.setDecimalPlaces(2)
assert $a == "10.100"
assert $b == "10.16"

# even more superflous tests

# empty init
assert `$`($$3) == "0.000"
# 1 dp
assert 109$$1 + 109$$1 == 218$$1
assert 109$$1 * 109$$1 == 1188$$1
assert $(10.999$$1)       == "11.0"
assert $(10.95$$1)        == "11.0"
assert $(10.94$$1)        == "10.9"
assert $(10.9111$$1)      == "10.9"
# 2 dp
assert 1099$$2 + 1099$$2 == 2198$$2
assert 1099$$2 * 1099$$2 == 12078$$2
assert $(10.99999$$2) == "11.00"
assert $(10.995$$2) == "11.00"
assert $(10.994$$2) == "10.99"
assert $(10.99111$$2) == "10.99"
# 3 dp
assert 10999$$3 + 10999$$3 == 21998$$3
assert 10999$$3 * 10999$$3 == 120978$$3
assert $(10000$$3) == "10.000"
assert $(10.9999999$$3) == "11.000"
assert $(10.9995$$3) == "11.000"
assert $(10.9994$$3) == "10.999"
assert $(10.999111$$3) == "10.999"
assert $(10.099$$3) == "10.099"
# 4 dp
assert 109999$$4 + 109999$$4 == 219998$$4
assert 109999$$4 * 109999$$4 == 1209978$$4
assert $(100000$$4) == "10.0000"
assert $(10.999999999$$4) == "11.0000"
assert $(10.99995$$4) == "11.0000"
assert $(10.99994$$4) == "10.9999"
assert $(10.9999111$$4) == "10.9999"
assert $(10.0099$$4) == "10.0099"
# rounding the rest correctly for multiplication
assert 106137$$4 * 103182$$4 == 1095143$$4 # 109.51427934
assert 1061$$2 * 1031$$2 == 10939$$2 # 109.3891

# subtraction
assert 1061$$2 - 1171$$2 == -110$$2
assert 1081$$2 - 1271$$2 == -190$$2
assert 1081$$2 - 1171$$2 == -90$$2
assert 1261$$2 - 1171$$2 == 90$$2
assert 1281$$2 - 1171$$2 == 110$$2

# division
assert 250$$2 / 500$$2 == 50$$2
assert 25$$1 / 500$$2 == 50$$2
assert `$`(100$$2 / 1234$$1) == "0.01"

# sign and 0
assert $(-90$$2) == "-0.90"
assert $(-190$$2) == "-1.90"

# string constructor allows for trailing zeros
assert `$`( $$"-0.90") == "-0.90"
assert `$`( $$"-10.90") == "-10.90"
assert `$`( $$"-10.0") == "-10.0"

# comparisons
assert $$"2.001" == $$2.001
assert $$"2.001" < $$2.002
assert $$"2.01"  > $$2.001
assert $$"2.002" > $$2.001

assert $$"2.001" <= $$2.001
assert $$"2.001" >= $$2.001
assert $$"2.001" <= $$2.002
assert $$"2.002" >= $$2.001

# conversion back to float
assert toFloat($$10.0) == 10.0
assert toInt($$10.6) == 11
