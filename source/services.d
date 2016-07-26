/**
 * A collection of query/service operations on sales invoices.
 */
module services;

private import models : SInvoice, SInvoiceLine;
private import std.algorithm.iteration : fold, map, joiner;
private import rangeutils : max, groupBy;
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
      (line) => new ProdPrice(line.product, line.price)
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

/**
 * Calculates the average price of each product in an array of invoices.
 * 
 * Params:
 *  invoices = the given invoices
 * Return: a range of tuples of type `Tuple!(string, "product", double, "price")`
 */
public auto avgProductPrices(SInvoice[] invoices)
in 
{
  assert(invoices.length > 0);
}
body 
{
  import std.range : array;
  alias PP = Tuple!(string, "product", double, "price");
  alias AvgData = Tuple!(double, "sum", size_t, "count");
  return invoices.map!(
    (invoice) => invoice.lines.map!(
      (line) => new PP(line.product, line.price)
    )
  ).joiner().groupBy!(
    (pp) => pp.product
  ).byKeyValue().map!(
    (kv) {
      auto result = new PP;
      result.product = kv.key;
      const auto avgData = kv.value.fold!(
        (acc, pp) {
          acc.sum += pp.price;
          acc.count++;
          return acc;
        }
      )(new AvgData(0.0, 0));
      result.price = avgData.sum / avgData.count;
      return result;
    }
  );
}

///
unittest
{
  import etl : load;
  import std.range : zip, array;
  import std.algorithm.comparison : equal;
  import std.stdio : writeln;
  import std.algorithm.iteration : each;
  import std.algorithm.sorting : sort;
  import std.math : cmp, approxEqual;

  auto actualAvgPrices = sort!(
    (pp1, pp2) => cmp(pp1.price, pp2.price) > 0
  )(
    avgProductPrices(
      load("test/sales-invoices-tiny-recurring-products.csv").array
    ).array
  );

  alias pp = Tuple!(string, "product", double, "price");
  auto expectedAvgPrices = [
    new pp("P-1887", 23.49),
    new pp("P-5207", 3.165),
    new pp("P-9327", 1.59),
    new pp("P-6294", 0.385)
  ];
  assert(
    equal!(
      (t1, t2) => t1.product == t2.product && approxEqual(t1.price, t2.price)
    )(actualAvgPrices, expectedAvgPrices)
  );
}
