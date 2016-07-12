/**
 * A collection of pretty printer functions when you need something fancier
 * than the basic `toString`.
 * 
 * Authors: Bahman Movaqar <Bahman AT BahmanM.com>
 * Copyright: Bahman Movaqar 2016-.
 */

module pprinter.sinvoice;

private import std.array : appender;
private import std.algorithm : each;
private import std.format : format;
private import std.range : repeat;
private import models : SInvoice, SInvoiceLine;

/**
 * A pretty printed string of a sales invoice as table with fancy ASCII chars.
 * Note that it doesn't touch STDOUT.
 * 
 * Params:
 *  si = the given sales invoice
 * Returns: a string representation of the invoice
 */
public auto ppSInvoice(in SInvoice si)
{
  if (si.lines.length == 0)
    return "ERROR: INVOICE WITH NO LINES.";
  else {
    auto result = appender!string();
    result.put(header(si));
    result.put(columns());
    si.lines[0..$-1].each!(line => result.put(siLine(line, false)));
    result.put(siLine(si.lines[$-1], true));
    result.put(footer(si));  
    return result.data;
  }
}

/**
 * Pretty prints a sales invoice header into a string.
 * 
 * Params:
 *  si = the given sales invoice
 * Returns: a string representation of the header
 */
private auto header(in SInvoice si) 
{
  auto result = appender!string();
  result.put(
    format(
      "%c%s%c\n", 
      '╔', repeat('═', 78), '╗'
    )
  );
  result.put(
    format(
      "║ %-38s%+38s ║\n",
      format("DATE: %s", si.docDate),
      format("DOC#: %s", si.docNo)
    )
  );
  result.put(
    format(
      "║ %-76s ║\n",
      format("CUSTOMER: %s", si.customer)
    )
  );
  result.put(
    format(
      "%c%s%c\n", 
      '╚', repeat('═', 78), '╝'
    )
  );
  return result.data;
}

/**
 * Pretty prints the sales invoice column headers into a string.
 * 
 * Returns: a string representation of the column headers
 */
private auto columns()
{
  auto result = appender!string();
  result.put(
    "┌─────┬──────────────────┬───────────┬───────────┬─────────────────────────────┐\n"
  );
  result.put(
    "│ #   │ PRODUCT          │ QTY       │ PRICE     │ AMT                         │\n"
  );
  result.put(
    "├─────┼──────────────────┼───────────┼───────────┼─────────────────────────────┤\n"
  );
  return result.data;
}

/**
 * Pretty prints a sales invoice line into a string.
 * 
 * Params:
 *  si = the given sales invoice line
 * Returns: a string representation of the sales invoice line
 */
private auto siLine(in SInvoiceLine sil, bool isLast)
{
  auto result = appender!string();
  result.put(
    format(
      "│ %-*d │ %-16s │ %-*d │ %-0.2*f │ %-0.2*f │\n",
      3, sil.lineNo,
      sil.product,
      9, sil.qty,
      9, sil.price,
      27, sil.lineAmt
    )
  );
  if (isLast)
    result.put(
      "└─────┴──────────────────┴───────────┼───────────┼─────────────────────────────┤\n"
    );
  else 
    result.put(
      "├─────┼──────────────────┼───────────┼───────────┼─────────────────────────────┤\n"
    );
  return result.data;
}

/**
 * Pretty prints a sales invoice footer into a string.
 * 
 * Params:
 *  si = the given sales invoice
 * Returns: a string representation of the footer
 */
private auto footer(in SInvoice si)
{
  auto result = appender!string();
  result.put(
    format(
      "                                     │ DISCOUNT%% │ %-0.2*f │\n",
      27, si.discount
    )
  );
  result.put(
    format(
      "                                     │ TOTAL     │ %-0.2*f │\n",
      27, si.totalAmt
    )
  );
  result.put(
    "                                     └───────────┴─────────────────────────────┘\n"
  );
  return result.data;
}