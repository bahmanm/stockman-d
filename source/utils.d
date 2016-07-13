/**
 * A collection of utility functions and templates.
 * 
 * Authors: Bahman Movaqar <Bahman AT BahmanM.com>
 * Copyright: Bahman Movaqar 2016-.
 */
module utils;

private import std.stdio;
private import std.algorithm.iteration;
private import std.range;
private import std.typecons;
private import std.traits;

private template GroupBy(alias clause, Range)
   if (isInputRange!Range)
{
  static alias ElemType = ElementType!Range;
  static alias GroupKeyType = typeof(clause(ElemType.init));
  static alias GroupByAAType = ElemType[][GroupKeyType];
  
  /***/
  auto groupBy(Range r)
  {
    GroupByAAType result;
    return r.fold!(
      function GroupByAAType(GroupByAAType acc, string val) {
        acc[clause(val)] ~= val;
        return acc;
      }
    )(result);
  }
}

/**
 * Groups a given range into partitions based on a given 'groupBy' clause.
 * Each group is identified by a key and consists of all elements of the range
 * with the same key.
 * 
 * For example:
 *   ["hi", "bahman", "nahid", "by", "sunny"].groupBy!(s => s.length)
 * wil yield:
 * [
 *  2: ["hi", "by"],
 *  6: ["bahman"],
 *  5: ["nahid", "sunny"]
 * ]
 * 
 * Note that there is no guarantee on the order of the AA keys.
 * 
 * Params:
 *  r = the given range
 *  clause = the 'groupBy' clause; a unary function with the signature
 *    GroupKeyType function(RangeElementType)
 * Returns: an AA of type ElemType[][GroupKeyType]
 * 
 */
public auto groupBy(alias clause, R)(R r)
  if (isInputRange!R)
{
  return GroupBy!(clause, R).groupBy(r);
}

unittest {
  // group strings by length
  const result1 = ["hi", "bahman", "nahid", "by", "sunny"]
    .groupBy!(s => s.length);
  assert(result1.length == 3);
  assert(result1[6].length == 1);
  assert(result1[6] == ["bahman"]);
  assert(result1[2].length == 2);
  assert(
    all!(
      (s => canFind(result1[2], s)), 
      ["hi", "by"]
    )
  );
  assert(result1[5].length == 2);
  assert(
    all!(
      (s => canFind(result1[5], s)), 
      ["nahid", "sunny"]
    )
  );
  
  // group integers by mod 2
  import std.algorithm.searching : all, canFind;
  const result2 = [1, 2, 3, 4, 5, 6, 7]
    .groupBy!(i => i % 2);
  assert(result2.length == 2);
  assert(result2[0].length == 3);
  assert(
    all!(
      (i => canFind(result2[0], i)), 
      [2, 4, 6]
    )
  );
  assert(result2[1].length == 4);
    assert(
    all!(
      (i => canFind(result2[1], i)), 
      [1, 3, 5, 7]
    )
  );
}