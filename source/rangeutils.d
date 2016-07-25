/**
 * A collection of range utility functions and templates.
 * 
 * Authors: Bahman Movaqar <Bahman AT BahmanM.com>
 * Copyright: Bahman Movaqar 2016-.
 */
module rangeutils;

private import std.stdio;
private import std.algorithm.iteration;
private import std.range;
private import std.typecons;
private import std.traits;

/**
 * Groups a given range into partitions based on a given "groupBy" clause.
 * Each group is identified by a key and consists of all elements of the range
 * with the same key.
 * 
 * Note that there is no guarantee on the order of the AA keys.
 * 
 * Params:
 *  r = the given range
 *  clause = the "groupBy" clause; a unary function with the signature
 *    `GroupKeyType function(RangeElementType)`
 * Returns: an AA of type `ElemType[][GroupKeyType]`
 * 
 */
public template groupBy(alias clause, Range)
  if (isInputRange!Range)
{
  static alias ElemType = ElementType!Range;
  static alias GroupKeyType = typeof(clause(ElemType.init));
  static alias GroupByAAType = ElemType[][GroupKeyType];
  
  // ditto
  auto groupBy(Range r)
  {
    GroupByAAType result;
    return r.fold!(
      function GroupByAAType(GroupByAAType acc, ElemType val) {
        acc[clause(val)] ~= val;
        return acc;
      }
    )(result);
  }
}

///
unittest {
  // group strings by length
  const result1 = ["hi", "bahman", "nahid", "by", "sunny"]
    .groupBy!(s => s.length);
  assert(result1.length == 3);
  assert(result1[6].length == 1);
  assert(result1[6] == ["bahman"]);
  assert(result1[2].length == 2);
  assert(
    result1[2].all!(
      s => ["hi", "by"].contains(s)
    )
  );
  assert(result1[5].length == 2);
  assert(
    result1[5].all!(
      s => ["nahid", "sunny"].contains(s)
    )
  );
  
  // group integers by mod 2
  const result2 = [1, 2, 3, 4, 5, 6, 7]
    .groupBy!(i => i % 2);
  assert(result2.length == 2);
  assert(result2[0].length == 3);
  assert(
    result2[0].all!(
      i => (cast(const(int)[]) [2, 4, 6]).contains(i)
    )
  );
  assert(result2[1].length == 4);
  assert(
    result2[1].all!(
      i => (cast(const(int)[]) [1, 3, 5, 7]).contains(i)
    )
  );
}

/**
 * Checks if a given predicate returns true on all elements of a given ranage.
 * 
 * Params:
 *  r = the given range
 * Returns: true if $(D_PARAM pred) returns true for all elements in 
 *  $(D_PARAM r)
 */
public auto all(alias pred, R)(R r)
  if (isInputRange!R)
{
  return r.fold!(
    (acc, e) => acc && pred(e)
  )(true);
}

///
unittest {
  assert([1,3,5].all!(i => i % 2 == 1));
  assert(![1,2,5].all!(i => i % 2 == 1));
}

/**
 * Checks if a given range contains a given element.
 * 
 * Params:
 *  r = the given range
 *  obj = the given element to look for
 * Returns: true if $(D_PARAM r) contains $(D_PARAM obj)
 */
public auto contains(R, E)(R r, E obj)
  if (isInputRange!R && is(E == ElementType!R))
{
  //TODO don't use 'filter'
  return !r.filter!(e => obj == e).empty;
}

///
unittest {
  assert([1,2,3].contains(2));
  assert(![1,2,3].contains(20));
}

/**
 * Finds the maximum element in a given range according to `comp` (comparator).
 * If two elements compete, the one closer to front of the range will win.
 * 
 * Params:
 *  r = the given `range`.
 *  comp = the (binary) comparator; should return an `int` (-1, 0, 1).
 * Returns: The maximum element of `r` according to `comp`.
 */
public auto max(alias comp, Range)(Range r)
in {
  assert(!r.empty);
}
body {
  auto seed = r.front;
  return r.dropOne().fold!(
    (acc, val) => comp(val, acc) > 0 ? val : acc
  )(seed);
}

///
unittest
{  
  // max of an int range
  assert(
    [1, 4, 2, 3].max!((i, j) => i - j) == 4
  );
  
  // longest of a string range 
  assert(
    ["hi", "by", "bahman", "nahid", "sunny"].max!(
      (s1, s2) => s1.length > s2.length ? 1 : 0
    ) == "bahman"
  );
  assert(
    ["hi", "by", "a"].max!(
      (s1, s2) => s1.length > s2.length ? 1 : 0
    ) == "hi"
  );
  
  // max of a range of structs
  struct S {
    public int i, j;
  }
  assert(
    [
      S(-1, 1), S(2, 0), S(100, -100), S(1, 1)
    ].max!(
      (s1, s2) => s1.i * s1.j - s2.i * s2.j
    ) == S(1, 1)
  );
}

unittest
{
  import core.exception : AssertError;
  import std.exception : assertThrown;
  
  assertThrown!AssertError(
    max!((i, j) => i - j)(cast(int[])[])
  );
  assertThrown!AssertError(
    max!((i, j) => i - j)(cast(int[])null)
  );
}

/**
 * Finds the minimum element in a given range according to `comp` (comparator).
 * If two elements compete, the one closer to front of the range will win.
 * 
 * Params:
 *  r = the given `range`.
 *  comp = the (binary) comparator; should return an `int` (-1, 0, 1).
 * Returns: The minimum element of `r` according to `comp`.
 */
public auto min(alias comp, Range)(Range r)
in {
  assert(!r.empty);
}
body {
  auto seed = r.front;
  return r.dropOne.fold!(
    (acc, val) => comp(val, acc) < 0 ? val : acc
  )(seed);
}

///
unittest
{
  // one element range
  assert(
    [1].min!((i, j) => i - j) == 1
  );
  
  // min of an int range
  assert(
    [4, 1, 2, 3].min!((i, j) => i - j) == 1
  );
  
  // longest of a string range 
  assert(
    ["hi", "bahman", "nahid", "sunny"].min!(
      (s1, s2) => s1.length < s2.length ? -1 : 0
    ) == "hi"
  );
  assert(
    ["hi", "by", "bahman", "nahid", "sunny"].min!(
      (s1, s2) => s1.length < s2.length ? -1 : 0
    ) == "hi"
  );
  
  // max of a range of structs
  struct S {
    public int i, j;
  }
  assert(
    [
      S(-1, 1), S(2, 0), S(100, -100), S(1, 1)
    ].min!(
      (s1, s2) => s1.i * s1.j - s2.i * s2.j
    ) == S(100, -100)
  );
}

unittest
{
  import core.exception : AssertError;
  import std.exception : assertThrown;
  
  assertThrown!AssertError(
    min!((i, j) => i - j)(cast(int[])[])
  );
  assertThrown!AssertError(
    min!((i, j) => i - j)(cast(int[])null)
  );
}