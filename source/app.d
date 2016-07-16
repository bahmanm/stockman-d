/**
 * Stockman entry point.
 * 
 * Authors: Bahman Movaqar <Bahman AT BahmanM.com>
 * Copyright: Bahman Movaqar 2016-.
 */
module app;

private import std.stdio : writeln;
private import std.algorithm : each;
private import etl : load;
private import std.conv : to;
private import std.format : format;
private import pprinter.sinvoice : ppSInvoice;

void main(string[] args)
{
  if (args.length != 2)
    writeln("ERROR: please pass the path to the CSV file.");
  else if (!isFileOk(args[1]))
    writeln("ERROR: the path doesn't exist or doesn't point to a file.");
  else
    load(args[1])
      .each!(line => writeln(ppSInvoice(line)));
}

/**
 * Checks if a given path exists and is a file.
 * 
 * Params:
 *  path = the given path
 * Returns: true if the path exists and is a file.
 */
private bool isFileOk(string path)
{
  import std.file : exists, isFile;
  return exists(path) && isFile(path);
}

unittest
{
  assert(!isFileOk("someNonExistingFile.someWeirdExtension"));
  assert(isFileOk("test/sales-invoices-tiny.csv"));
  assert(!isFileOk("./test/"));
}