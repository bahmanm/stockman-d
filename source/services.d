/**
 * A collection of query/service operations on sales invoices.
 */
module services;

private import models : SInvoice, SInvoiceLine;
private import std.algorithm.iteration : fold;

/**
 * Calculates the sum of total amounts of an array of invoices.
 * 
 * Params:
 *  invoices = the given invoices
 * Return: the sum of total amounts
 */
public double totalSales(SInvoice[] invoices)
in {
  assert(invoices != null && invoices.length > 0);
}
body {
  return invoices.fold!(
    (acc, invoice) => acc + invoice.totalAmt
  )(0.0);
}

///
unittest
{
  assert(
    totalSales([
      SInvoice("d1", "20160101", "c1", 0.0, 10.66, [])
    ]) == 10.66
  );
  assert(
    totalSales([
      SInvoice("d1", "20160101", "c1", 0.0, 100.0, []),
      SInvoice("d1", "20160101", "c1", 0.0, 200.0, []),
      SInvoice("d1", "20160101", "c1", 0.0, 50.61, []),
      SInvoice("d1", "20160101", "c1", 0.0, 20.01, [])
    ]) == 370.62
  );
}