# Clean up the previous R scripts + add logging 
## Set up libraries
library(binancer)
library(httr)
library(data.table)
library(logger)
library(scales)


forint <- function(x) {
  dollar(x, prefix = '', suffix = ' HUF')
}


#################################

## contsants
BITCOINS <- 0.42

#################################

## Bitcoin price in USD
coin_prices <- binance_coins_prices()

## Print number of bitcoins on Binance
log_info('Found {coin_prices[, .N]} coins on Binance')

## Storing the price of bitcoin
btcusd <- coin_prices[symbol=='BTC', usd]

## printing out the price of it
log_info('The current BTC prices is {btcusd} in USD')

## getting the exchange rate from the public API
response <- GET('https://api.exchangeratesapi.io/latest?base=USD')
exchange_rates <- content(response)
usdhuf <- exchange_rates$rates$HUF

## print it out in 000s of HUF
log_info('The current USD price is {round(usdhuf/1000,2)} in HUF')
format(usdhuf, digits = 6, big.mark = ',') #options


########## Report

BITCOINS*btcusd*usdhuf


