/**
 * A collection of query/service operations on sales invoices.
 */
module services;

private import models : SInvoice, SInvoiceLine;
private import std.algorithm.iteration : fold, map;
private import rangeutils : max;
private import std.typecons : Tuple;

/**
 * Calculates the sum of total amounts of an array of invoices.
 * 
 * Params:
 *  invoices = the given invoices
 * Return: the sum of total amounts
 */
public auto totalSales(SInvoice[] invoices)
in 
{
  assert(invoices.length > 0);
}
body 
{
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

/**
 * Finds the most expensive invoice (based on total amount)
 * in an array of invoices. 
 * 
 * Params:
 *  invoices = the given array of invoices
 * Return: the invoice with the largest total amount
 */
public auto mostExpensive(SInvoice[] invoices)
in 
{
  assert(invoices.length > 0);
}
body 
{
  return invoices.max!((i1, i2) => i1.totalAmt - i2.totalAmt);
}

///
unittest
{
  assert(
    mostExpensive([
      SInvoice("d1", "20160101", "c1", 0.0, 10.66, [])
    ]) == SInvoice("d1", "20160101", "c1", 0.0, 10.66, [])
  );
  assert(
    mostExpensive([
      SInvoice("d1", "20160101", "c1", 0.0, 100.0, []),
      SInvoice("d1", "20160101", "c1", 0.0, 200.0, []),
      SInvoice("d1", "20160101", "c1", 0.0, 50.61, []),
      SInvoice("d1", "20160101", "c1", 0.0, 20.01, [])
    ]) == SInvoice("d1", "20160101", "c1", 0.0, 200.0, [])
  );
}

/**
 * Finds the most expensive product (based on price) in an array
 * of invoices.
 * 
 * Params:
 *  invoices = the given array of invoices
 * Return: the product name  
 */
public auto mostExpensiveProduct(SInvoice[] invoices)
in 
{
  assert(invoices.length > 0);
}
body 
{
  alias ProdPrice = Tuple!(string, "product", double, "price");
  return invoices.map!(
    (invoice) => invoice.lines.map!(
      (line) {
        auto pp = new ProdPrice;
        pp.product = line.product;
        pp.price = line.price;
        return pp;
      }
    )
  ).map!(  // the most expensive product in each invoice
    (prodPrices) => prodPrices.max!(
      (pp1, pp2) => pp1.price - pp2.price
    ) 
  ).max!( // the most expensive product of all invoices
    (pp1, pp2) => pp1.price - pp2.price
  ).product;
}

///
unittest
{
  import etl : load;
  import std.range : array;
  assert(
    mostExpensiveProduct(
      load("test/sales-invoices-tiny.csv").array
    ) == "P-0674"
  );
}

