/**
 * Stockman entry point.
 * 
 * Authors: Bahman Movaqar <Bahman AT BahmanM.com>
 * Copyright: Bahman Movaqar 2016-.
 */
module app;

private import std.stdio : writeln;
private import etl : load;
private import std.conv : to;
private import std.format : format;
private import models : SInvoice;
private import std.algorithm : each;
private import std.math : cmp;
private import std.algorithm.sorting : sort;
private import std.range : array;

void main(string[] args)
{
  if (args.length != 2)
    writeln("ERROR: please pass the path to the CSV file.");
  else if (!isFileOk(args[1]))
    writeln("ERROR: the path doesn't exist or doesn't point to a file.");
  else {
    auto invoices = load(args[1]).array;
    printTotalSales(invoices);
    pprintMostExpensiveInvoice(invoices);
    printMostExpensiveProduct(invoices);
    printProductPriceAvg(invoices);
    printTotalByCustomer(invoices);
    printCustomerWithMaxTotal(invoices);
    printCustomersWithMinTotal(invoices);
    printDateWithMaxTotal(invoices);
  }
}

private void printTotalSales(SInvoice[] invoices)
{
  import services : totalSales;
  writeln(
    format (
      "\n>>Total sales: %0.2f\n",
      invoices.totalSales
    )
  );
}

private void pprintMostExpensiveInvoice(SInvoice[] invoices)
{
  import pprinter.sinvoice : ppSInvoice;
  import services : mostExpensive;
  writeln(
    format(
      "\n>>Most expensive invoice:\n%s\n",
      ppSInvoice(invoices.mostExpensive)
    )
  );
}

private void printMostExpensiveProduct(SInvoice[] invoices)
{
  import services : mostExpensiveProduct;
  writeln(
    format(
      "\n>>Most expensive product: [%s]\n",
      invoices.mostExpensiveProduct
    )
  );
}

private void printProductPriceAvg(SInvoice[] invoices)
{
  import services : avgProductPrices;
  writeln("\n>>Price average per each product:");
  sort!(
    (t1, t2) => cmp(t1.price, t2.price) > 0
  )(
    invoices.avgProductPrices.array
  ).each!(
    pp => writeln(
      format("%s, %0.2f", pp.product, pp.price)
    )
  );
}

private void printTotalByCustomer(SInvoice[] invoices)
{
  import services : totalByCustomer;
  writeln("\n>>Total sales per customer:");
  sort!(
    (t1, t2) => cmp(t1.total, t2.total) > 0
  )(
    invoices.totalByCustomer.array
  ).each!(
    cs => writeln(
      format("%s, %0.2f", cs.customer, cs.total)
    )
  );
}

private void printCustomerWithMaxTotal(SInvoice[] invoices)
{
  import services : customerWithMaxTotal;
  writeln(
    format(
      "\n>>Customer with max total sales: %s\n",
      invoices.customerWithMaxTotal.customer
    )
  );
}

private void printCustomersWithMinTotal(SInvoice[] invoices)
{
  import services : customersWithMinTotal;
  import std.range : retro;
  writeln("\n>>Customers with min total sales:");
  invoices.customersWithMinTotal(3).retro.each!(
    cs => writeln(
      format("%s, %0.2f\n", cs.customer, cs.total)
    )
  );
}

private void printDateWithMaxTotal(SInvoice[] invoices)
{
  import services : datesWithMaxTotal;
  writeln(
    format(
      "\n>>Date with max total sales: %s", 
      invoices.datesWithMaxTotal.front.date
    )
  );
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