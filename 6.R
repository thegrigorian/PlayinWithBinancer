library(binancer)
library(httr)
library(data.table)
library(logger)
library(scales)
library(ggplot2)



forint <- function(x) {
  dollar(x, prefix = '', suffix = ' HUF')
}

## ########################################################
## ~CONSTANTS

BITCOINS <- 0.42
ETHEREUMS <- 1.2

## ########################################################
## Loading data


### EXCHANGE RATE PART
## USD in HUF
response <- GET(
  'https://api.exchangeratesapi.io/history',
  query = list(
    start_at = Sys.Date() - 40,
    end_at   = Sys.Date(),
    base     = 'USD',
    symbols  = 'HUF'
  ))


exchange_rates <- content(response)
str(exchange_rates)
exchange_rates <- exchange_rates$rates

library(data.table)
usdhufs <- data.table(
  date = as.Date(names(exchange_rates)),
  usdhuf = as.numeric(unlist(exchange_rates)))
str(usdhufs)

#######################################################################################

## Bitcoin price in USD
btc_prices <- binance_klines('BTCUSDT', interval = '1d', limit = 30)
eth_prices <- binance_klines('ETHUSDT', interval = '1d', limit = 30)
coin_prices <- rbind(btc_prices, eth_prices)
str(coin_prices)


balance <- rbindlist(lapply(c('BTC', 'ETH'), function(s) {
 binance_klines(paste0(s, 'USDT'), interval = '1d', limit = 30)[, .(
   date=as.Date(close_time),
   usdt = close, 
   symbol = s
 )]
  }))

balance[, amount :=switch (
  symbol, 
  'BTC' = BITCOINS, 
  'ETH' = ETHEREUMS, 
  stop('Unsupported coin')), 
  by = symbol]
str(balance)

## rolling join
setkey(balance, date)
setkey(usdhufs, date)

balance <- usdhufs[balance, roll = TRUE] ## DT[i, j, by = ...]

str(balance)

balance[, value := amount * usdhuf * usdt]
str(balance)

## ########################################################
## Report

ggplot(balance, aes(date, value, fill = symbol)) + 
  geom_col() +
  xlab('') +
  ylab('') + 
  scale_y_continuous(labels = forint) +
  theme_bw() +
  ggtitle('My crypto fortune',
          subtitle = balance[date == max(date), paste(paste(amount, symbol), collapse = ' + ')])


          
          
          