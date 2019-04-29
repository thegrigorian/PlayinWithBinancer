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

## ########################################################
## Loading data

## USD in HUF
?GET
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

## Bitcoin price in USD
coin_prices <- binance_klines('BTCUSDT', interval = '1d', limit = 30)
str(coin_prices)

balance <- coin_prices[, .(date = as.Date(close_time), btcusd = close)]
str(balance)
str(usdhufs)

x <- merge(balance, usdhufs, by = 'date', all.x = TRUE)

## rolling join
setkey(balance, date)
setkey(usdhufs, date)
balance <- usdhufs[balance, roll = TRUE] ## DT[i, j, by = ...]

str(balance)

balance[, btchuf := btcusd * usdhuf]
balance[, btc := BITCOINS]
balance[, value := btc * btchuf]
str(balance)

## ########################################################
## Report

ggplot(balance, aes(date, value)) + 
  geom_line() +
  xlab('') +
  ylab('') + 
  scale_y_continuous(labels = forint) +
  theme_bw() +
  ggtitle('My crypto fortune',
          subtitle = paste(BITCOINS, 'BTC'))