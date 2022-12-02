## This is a library for [Fixed-point](https://en.wikipedia.org/wiki/Fixed-point_arithmetic) numbers in [Nim](https://nim-lang.org/).

import std/[math, strutils]
# import print

# TODO: operations working with int/float without converting to FixedPoint first
# TODO: make FixedPoint generic, maybe with generator template

type
  FixedPoint* = object
    decimalPlaces: int
    number: int
  DecimalStrategy* = enum
    ## strategy when operating on 2 FixedPoints with different `decimalPlaces`
    ## either keep more decimalPlaces or less
    dsKeepMore
    dsKeepLess

var defaultDecimalStrategy*: DecimalStrategy = dsKeepMore

proc setDecimalPlaces*(a: var FixedPoint, decimalPlaces: int) =
  ## changes the `number` in `a` according to the new `decimalPlaces`
  let dPdiff = a.decimalPlaces - decimalPlaces
  if dPdiff != 0:
    a.decimalPlaces = decimalPlaces
    let
      divisor = 10 ^ dPdiff.abs
    if dPdiff < 0:
      a.number *= divisor
    else:
      var temp = a.number div divisor
      # round up
      if ((a.number mod divisor) div (divisor div 10)) > 4:
        temp += 1
      a.number = temp

template setDecimalPlaces*(a: var FixedPoint, b: FixedPoint) =
  setDecimalPlaces(a, b.decimalPlaces)

proc fixedPoint*(decimalPlaces: int): FixedPoint =
  ## new FixedPoint with `number=0`, just specify `decimalPlaces`
  FixedPoint(decimalPlaces: decimalPlaces)

proc fixedPoint*(a: int, decimalPlaces: int): FixedPoint =
  ## new FixedPoint from int with specified `decimalPlaces`
  FixedPoint(number: a, decimalPlaces: decimalPlaces)

proc fixedPoint*(a: string): FixedPoint =
  ## new FixedPoint from string, `decimalPlaces` are inferred
  var str = a
  let dotPos = str.find('.')
  assert str.find('e') == -1, "doesn't work with exponent representation atm"
  assert dotPos != -1, "needs a '.' to determine decimalPlaces"
  let actualDecimalPlaces = str.len - dotPos - 1
  str.delete(dotPos..dotPos)
  FixedPoint(
    number: str.parseInt,
    decimalPlaces: actualDecimalPlaces
  )

proc fixedPoint*(a: float, decimalPlaces = 0): FixedPoint =
  ## new FixedPoint from float with specified `decimalPlaces`
  ## decimalPlaces are inferred if == 0
  ## this converts to string and back and thus is a little expensive
  var str = $a
  let dotPos = str.find('.')
  assert str.find('e') == -1, "doesn't work with exponent representation atm"
  assert dotPos != -1, "needs a '.' to determine decimalPlaces"
  let actualDecimalPlaces = str.len - dotPos - 1
  if decimalPlaces != 0:
    var dPdiff = decimalPlaces - actualDecimalPlaces
    if dPdiff < 0:
      str = `$`(a.round(decimalPlaces))
      # rounding can leave the float with too many decimalPlaces because of float inaccuracy
      # eg 0.5641666666666667.round(2) = 0.5600000000000001
      if str.len - dotPos > decimalPlaces:
        str = str[0..dotPos+decimalPlaces]
      # rounding can reduce decimalPlaces too much, by cutting trailing zeros
      dPdiff = decimalPlaces - (str.len - str.find(".") - 1)
      if dPdiff > 0:
        str &= '0'.repeat(dPdiff)
    elif dPdiff > 0:
      str &= '0'.repeat(dPdiff)
  str.delete(dotPos..dotPos)
  FixedPoint(
    number: str.parseInt,
    decimalPlaces:
    if decimalPlaces != 0: decimalPlaces
    else: actualDecimalPlaces
  )

template `$$`*(decimalPlaces: int): FixedPoint =
  fixedPoint(decimalPlaces)

template `$$`*(a: int, decimalPlaces: int): FixedPoint =
  fixedPoint(a, decimalPlaces)

template `$$`*(a: string): FixedPoint =
  fixedPoint(a)

template `$$`*(a: float, decimalPlaces = 0): FixedPoint =
  fixedPoint(a, decimalPlaces)

proc toFloat*(a: FixedPoint): float =
  a.number / 10^a.decimalPlaces

template toInt*(a: FixedPoint): int =
  a.toFloat.round.int

proc `<`*(a, b: FixedPoint): bool =
  let dPdiff = a.decimalPlaces - b.decimalPlaces
  if dPdiff != 0:
    var
      tempa = a
      tempb = b
    tempa.setDecimalPlaces(tempb)
    tempa.number < tempb.number
  else:
    a.number < b.number

template `>`*(a, b: FixedPoint): bool =
  (b < a)

template `<=`*(a, b: FixedPoint): bool =
  ((a == b) or (a < b))

template `>=`*(a, b: FixedPoint): bool =
  ((a == b) or (a > b))

proc `+`*(a, b: FixedPoint, decimalStrategy = defaultDecimalStrategy): FixedPoint =
  let dPdiff = a.decimalPlaces - b.decimalPlaces
  if dPdiff != 0:
    var
      less = if dPdiff < 0: a else: b
      more = if less == a: b else: a
    case decimalStrategy:
      of dsKeepMore:
        less.setDecimalPlaces(more)
      of dsKeepLess:
        more.setDecimalPlaces(less)
    FixedPoint(number: less.number+more.number,
        decimalPlaces: less.decimalPlaces)
  else:
    FixedPoint(number: a.number+b.number, decimalPlaces: a.decimalPlaces)

proc `-`*(a: FixedPoint): FixedPoint =
  FixedPoint(number: -a.number, decimalPlaces: a.decimalPlaces)

template `-`*(a, b: FixedPoint, decimalStrategy = defaultDecimalStrategy): FixedPoint =
  `+`(a, (-b), decimalStrategy)

proc `*`*(a, b: FixedPoint, decimalStrategy = defaultDecimalStrategy): FixedPoint =
  try:
    result = FixedPoint(number: a.number*b.number,
                        decimalPlaces: a.decimalPlaces+b.decimalPlaces)
  except OverflowDefect:
    result = fixedPoint(a.toFloat*b.toFloat)
  let dPdiff = a.decimalPlaces - b.decimalPlaces
  if dPdiff != 0:
    var
      less = if dPdiff < 0: a else: b
      more = if less == a: b else: a
    case decimalStrategy:
      of dsKeepMore:
        result.setDecimalPlaces(more)
      of dsKeepLess:
        result.setDecimalPlaces(less)
  else:
    result.setDecimalPlaces(a)

proc `/`*(a, b: FixedPoint, decimalStrategy = defaultDecimalStrategy): FixedPoint =
  ## this converts to float and back and is thus a little slow
  let dPdiff = a.decimalPlaces - b.decimalPlaces
  if dPdiff != 0:
    var
      lessIsA = false
      less = if dPdiff < 0: lessIsA = true; a else: b
      more = if lessIsA: b else: a
    case decimalStrategy:
      of dsKeepMore:
        less.setDecimalPlaces(more)
      of dsKeepLess:
        more.setDecimalPlaces(less)
    # order matters of division matters
    if lessIsA: fixedPoint(less.number / more.number, less.decimalPlaces)
    else: fixedPoint(more.number / less.number, less.decimalPlaces)
  else:
    fixedPoint(a.number / b.number, a.decimalPlaces)

template `+=`*(a: var FixedPoint, b: FixedPoint,
    decimalStrategy = defaultDecimalStrategy) =
  a = `+`(a, b, decimalStrategy)

template `-=`*(a: var FixedPoint, b: FixedPoint,
    decimalStrategy = defaultDecimalStrategy) =
  a = `-`(a, b, decimalStrategy)

template `*=`*(a: var FixedPoint, b: FixedPoint,
               decimalStrategy = defaultDecimalStrategy) =
  a = `*`(a, b, decimalStrategy)

template `/=`*(a: var FixedPoint, b: FixedPoint,
               decimalStrategy = defaultDecimalStrategy) =
  a = `/`(a, b, decimalStrategy)

proc `$`*(a: FixedPoint): string =
  # TODO: missing logic for a case (number: 1, decimalPlaces: 2) ie 0.01
  let splitSign = `$`(a.number).split('-', maxsplit = 1)
  var
    sign = ""
    number = ""
  if splitSign.len == 2:
    sign = "-"
    number = splitSign[1]
  else:
    sign = ""
    number = splitSign[0]
  let
    numberLen = number.len
    beforeIndex = numberLen - (a.decimalPlaces+1)
    afterIndex = numberLen - (a.decimalPlaces)
  var
    before = ""
    after = ""
  if beforeIndex < 0: before = "0"
  else: before = number[0..beforeIndex]
  if afterIndex < 0:
    after = '0'.repeat(-afterIndex)
    after &= number
  else: after = number[afterIndex..^1]
  result = sign & before & "." & after

# when isMainModule:
