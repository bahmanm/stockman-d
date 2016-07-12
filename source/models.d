/**
 * Stockman model entities.
 * 
 * Authors: Bahman Movaqar <Bahman AT BahmanM.com>
 * Copyright: Bahman Movaqar 2016-.
 */

module models;

private import std.array : appender;
private import std.algorithm : each;
private import std.format : format;
private import std.range : repeat;

/**
 * Represents a sales invoice line.
 */
public struct SInvoiceLine
{
  /** line # */
  public int lineNo;
  /** product code */
  public string product;
  /** line quantity */
  public uint qty;
  /** product price */
  public double price;
  /** line amount */
  public double lineAmt;
  
  public string toString() const @safe
  {
    return format(
      "SInvoiceLine(%d, %s, %d, %0.2f, %0.2f)",
      lineNo, product, qty, price, lineAmt
    );
  }
  
}

/**
 * Represents a sales invoice.
 */
public struct SInvoice
{
  /** invoice # */
  public string docNo;
  /** invoice date */
  public string docDate;
  /** customer code */
  public string customer;
  /** invoice total discount % */
  public float discount;
  /** invoice total amount */
  public double totalAmt;
  /** invoice lines */
  public SInvoiceLine[] lines;
  
  public string toString() const @safe
  {
    auto result = appender!string();
    result.put(
      format(
        "SInvoice(%s, %s, %s, %0.2f, %0.2f)\n", 
        docNo, docDate, customer, discount, totalAmt
      )
    );
    lines.each!(line => result.put(format("  %s\n", line)));
    return result.data;
  }
  
}