
## We have 0.42 Bitcoin -- let's report on the value of this asset in USD

library(devtools)
install_github("daroczig/binancer")
library(binancer)

coin_prices <- binance_ticker_all_prices()

str(coin_prices)

coin_prices[to=='BTC'][1, to_usd]


coin_prices <- binance_coins_prices()
str(coin_prices)
coin_prices[symbol=='BTC', usd *0.42]