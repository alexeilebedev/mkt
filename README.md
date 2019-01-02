Mkt is a personal-use command-line price query tool.
It can query stocks, cryptocurrencies, currencies, and fed interest rates,
using an extensible mechanism, and display results in any currency.

Supported sources:
~~~
    iex
    ecb (European Central Bank)
    hitbtc
    ustreasury - for looking up interest rates
~~~
  
mkt reads a file, by default data/symbol, retrieves quotes, and prints
the result to stdout. Example contents of symbol file:
~~~
    BTC hitbtc
    SPY iex
    EUR ecb
~~~

Example output:
~~~
    BTC   3339.73000   2018-12-16T21:52:06.371Z
    SPY    260.47000   2018-12-14T21:00:00.500Z
    EUR      1.12850   2018-12-14T05:00:00 
~~~

Symbols support a generalized format, "A/B" where price of A is quoted in
terms of B. mkt default currency is USD, this can be changed with -ccy option.
~~~
    $ mkt -ccy BTC
    Times are in GMT. Currency is BTC
    BTC          1.00000   2018-12-17T00:09:31.557Z
    SPY          0.07857   2018-12-17T00:09:31.557Z
    EUR          0.00034   2018-12-17T00:09:31.557Z
~~~

Mkt builds out two levels of implieds based on whatever data it fetches.
Interest rates are currency-independent and have to be specified as "/1", i.e. "TB52/1"
for 52-week treasury bills (bond equivalent, i.e. 365-day). 

Currency can be any symbol. mkt -ccy TSLA will display all quotes in terms
of exchange rate with TSLA. A limitation is that TSLA must appear in the symbol list,
otherwise its price will be undefined.

Whenever the symbol file specifies an absolute pair, e.g. EUR/USD, that pair is displayed as-is.
Otherwise, it is interpreted as /<ccy>, and can vary on output.
