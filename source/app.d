/**
 * Stockman entry point.
 * 
 * Authors: Bahman Movaqar <Bahman AT BahmanM.com>
 * Copyright: Bahman Movaqar 2016-.
 */

private import std.stdio : writeln;
private import std.algorithm : each;
private import etl : load;
private import std.conv : to;
private import std.format : format;
private import pprinter.sinvoice : ppSInvoice;

void main(string[] args)
{
  if (args.length != 2) {
    writeln("ERROR: please pass the path to the CSV file.");
  } else {
    load(args[1])
    .each!(line => writeln(ppSInvoice(line)));
  }
}