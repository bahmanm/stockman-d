/**
 * A collection of ETL (extract, trasnform & load) methods.
 * Basically this module is responsible for import (and exporting) entities.
 * 
 * Authors: Bahman Movaqar <Bahman AT BahmanM.com>
 * Copyright: Bahman Movaqar 2016-.
 */
module etl;

private import std.stdio : writeln, File;
private import std.algorithm : each, map;
private import std.algorithm.iteration : fold, map, filter, chunkBy;
private import std.typecons : tuple, Tuple;
private import std.array : split, array;
private import std.conv : to;
private import std.range : drop;
private import models;


/**
 * Loads a file into an array of strings by line.
 * 
 * Params:
 *  path = the path to the file
 *  nHeaderLine = number of headers lines to discard when reading the
 *    file (defaults to 1)
 * Returns: a range of SInvoices.
 */
public auto load(string path, int nHeaderLine=1)
{
  //TODO check for file existence
  return combineOneLiners(
    File(path)
    .byLine
    .drop(nHeaderLine)
    .map!(line => tranformLine(line))
  );    
}

unittest
{
  
}

/**
 * Transforms a given line of input (e.g. from file) to a SalesInvoice.
 * Note that the SalesInvoice it creates will contain only one invoice line,
 * that is the line that is passed.  To create a meaningful invoice, one has
 * to pass all the one-liner invoices to `combineOneLiners`.
 * 
 * Params:
 *  line = the given line of input
 * Returns: a SalesInvoice
 */
private auto tranformLine(in char[] line)
{
  auto fields = line.split(',');
  return SInvoice(
    to!string(fields[0]),   // docNo
    to!string(fields[2]),   // customer
    to!string(fields[1]),   // docDate
    to!float(fields[4]),    // discount
    to!double(fields[3]),   // totalAmt
    [
      SInvoiceLine(
        to!int(fields[5]),      // lineNo
        to!string(fields[6]),   // product
        to!uint(fields[7]),     // qty
        to!double(fields[8]),   // price
        to!double(fields[9])    // lineAmt
      )
    ]
  );
}

unittest 
{
  auto si = tranformLine(
    "SI-368,C551,2016/1/17,256799.49,17,1,P-3731,6,2.60,15.60"
  );
  assert(si.docNo == "SI-368");
  assert(si.customer == "C551");
  assert(si.docDate == "2016/1/17");
  assert(si.discount == 17);
  assert(si.totalAmt == 256_799.49);
  assert(si.lines.length == 1);
  assert(si.lines[0].lineNo == 1);
  assert(si.lines[0].product == "P-3731");
  assert(si.lines[0].qty == 6);
  assert(si.lines[0].price == 2.60);
  assert(si.lines[0].lineAmt == 15.60);
}

/**
 * Combines a range of one-liner sales invoices into real invoices.
 * It groups the one-liners based on the `docNo` field and combines the lines.
 * 
 * Params:
 *  oneLiners = a range of one-liner invoices
 * Returns: a range of "combined" invoices.
 */
private auto combineOneLiners(R)(R oneLiners)
{
  return oneLiners.chunkBy!(si => si.docNo).map!(
    function SInvoice(ref auto group) {
      auto refInvoice = group[1].front;
      group[1].popFront();
      return group[1].fold!(
        function SInvoice(SInvoice fixed, SInvoice oneLiner) {
          fixed.lines ~= oneLiner.lines[0];
          return fixed;
        }
      )(refInvoice);
    }
  );
}

unittest 
{
  auto si1 = SInvoice(
    "D1", "DATE", "CUST1", 0.0, 100.0, 
    [SInvoiceLine(1, "P1", 10, 5.0, 50.0)]
  );
  auto si2 = SInvoice(
    "D1", "DATE", "CUST1", 0.0, 100.0, 
    [SInvoiceLine(2, "P2", 2, 25.0, 50.0)]
  );
  auto si3 = SInvoice(
    "D2", "DATE", "CUST1", 0.0, 100.0,
    [SInvoiceLine(1, "P1", 20, 5.0, 100.0)]
  );
  auto result = combineOneLiners([si1, si2, si3]).array;
  assert(result.length == 2);
  assert(result.filter!(si => si.docNo == "D1").array.length == 1);
  assert(result.filter!(si => si.docNo == "D1").array[0].lines.length == 2);
  assert(result.filter!(si => si.docNo == "D2").array.length == 1);
  assert(result.filter!(si => si.docNo == "D2").array[0].lines.length == 1);
}