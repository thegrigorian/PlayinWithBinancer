## We have 0.42 Bitcoin 
## let's report on the value of this asset 
## for the past 30 days in HUF


# Clean up the previous R scripts + add logging 
## Set up libraries
library(binancer)
library(httr)
library(data.table)
library(logger)
library(scales)
library(ggplot2)

forint <- function(x) {
  dollar(x, prefix = '', suffix = ' HUF')
}


## getting the exchange rate from the public API
response <- GET('https://api.exchangeratesapi.io/latest?base=USD')
exchange_rates <- content(response)
usdhuf <- exchange_rates$rates$HUF

#################################

## contsants
BITCOINS <- 0.42

#################################

## Bitcoin price in USD
coin_prices <- binance_klines("BTCUSDT", interval='1d', limit = 30)
str(coin_prices)

balance <- coin_prices[, .(date=as.Date(close_time), btcusd = close)]

str(balance)

balance[, btchuf := btcusd * usdhuf]
balance[, btc := BITCOINS]
balance[, value := btchuf * btc]

#################################
ggplot(balance, aes(date, value)) + 
  geom_line() +
   xlab('') +
   ylab('') +
   scale_y_continuous(labels = forint) +
   theme_bw() + 
   ggtitle('My crypto fortune', 
           subtitle =  paste((BITCOINS), 'BTC'))
  