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

/**/
public auto all(alias clause, R)(R r)
  if (isInputRange!R)
{
  return r.fold!(
    (acc, e) => acc && clause(e)
  )(true);
}

unittest {
  assert([1,3,5].all!(i => i % 2 == 1));
  assert(![1,2,5].all!(i => i % 2 == 1));
}

/**/
public auto contains(R, E)(R r, E obj)
  if (isInputRange!R && is(E == ElementType!R))
{
  return !r.filter!(e => obj == e).empty;
}


unittest {
  assert([1,2,3].contains(2));
  assert(![1,2,3].contains(20));
}