
## We have 0.42 Bitcoin -- let's report on the value of this asset in HUF


library(httr) #HTTP requests from R 

response <- GET('https://api.exchangeratesapi.io/latest?base=USD')
headers(response)

exchange_rates <- content(response)

usdhuf <- exchange_rates$rates$HUF


coin_prices <- binance_coins_prices()
str(coin_prices)
coin_prices[symbol=='BTC', usd *0.42*usdhuf]

## NOTE helper R function
## NOTE error handling

bitcoin_to_huf<- function(bitcoin) {
  library(binancer)
  exchange_rates <- content(response)
  usdhuf <- exchange_rates$rates$HUF
  coin_prices <- tryCatch(
    binance_coins_prices(), 
    error = function(e) {
    print(e$message)
    binance_coins_prices()
    })
  
  return(coin_prices[symbol=='BTC', usd *bitcoin*usdhuf])
}

bitcoin_to_huf(0.42)


