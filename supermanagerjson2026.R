
library(jsonlite)
library(tidyverse)
library(httr)


# cabeceras
headers <- c(
  "Authorization" = Sys.getenv("SM_TOKEN"),
  "Accept" = "application/json"
)


# Headers necesarios
headers <- c(
  "Accept" = "application/json, text/plain, */*",
  "Accept-Encoding" = "gzip, deflate, br, zstd",
  "Accept-Language" = "es-ES,es;q=0.9,en;q=0.8",
  "Authorization" = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjZWI4ZWMyNjQzN2Q0MGEwODI5NDVmYjJiYTgzMmIwYyIsInN1YiI6IjE1MDkwIiwic2NvcGUiOlsiYmFzaWMiXSwiZXhwIjoxNzYxODE2NTQxfQ.fZwk-GyWXoaQnW_5w72JGpwOXIEztB1snXAzq7gmYdE",
  "Cache-Control" = "no-cache",
  "Pragma" = "no-cache",
  "Referer" = "https://supermanager.acb.com/market?position=1",
  "Sec-Ch-Ua" = "\"Not/A)Brand\";v=\"8\", \"Chromium\";v=\"126\", \"Google Chrome\";v=\"126\"",
  "Sec-Ch-Ua-Mobile" = "?0",
  "Sec-Ch-Ua-Platform" = "\"macOS\"",
  "Sec-Fetch-Dest" = "empty",
  "Sec-Fetch-Mode" = "cors",
  "Sec-Fetch-Site" = "same-origin",
  "User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
)

# URL de la API
url <- "https://supermanager.acb.com/api/basic/player?_filters=%5B%7B%22field%22:%22competition.idCompetition%22,%22value%22:1,%22operator%22:%22=%22,%22condition%22:%22AND%22%7D,%7B%22field%22:%22edition.isActive%22,%22value%22:true,%22operator%22:%22=%22,%22condition%22:%22AND%22%7D%5D&_page=1&_perPage=30&_sort=%5B%7B%22field%22:%22price%22,%22type%22:%22DESC%22%7D%5D"

# Hacer la solicitud GET
response <- GET(url, add_headers(.headers = headers))

content <- content(response, "text", encoding = "UTF-8")

superManager <- fromJSON(content, flatten = TRUE) %>%
  unnest_wider(playerStats) %>%
  mutate(imageTeamNegative = paste0("https://supermanager.acb.com/files/logo/", imageTeamNegative))

write_csv(superManager,here::here("2026", "supermanager", "basicos", "datosjugadores", "csv", "superManager.csv"))
write_rds(superManager,here::here("2025", "superManager", "rds", "superManager.rds"))
# stats_boxscores <- readRDS(here::here("2025", "PlayByPlay", "acb2425", "rds", "boxscores_2425.rds")) %>%
#   select(id_license, fullName,nick, shortName, isExtraCommunity, isNational, price, license,  position, nameTeam )



# info por jugador --------------------------------------------------------

headers <- c(
  "authority"="supermanager.acb.com",
  "method"="GET",
  "path"="/api/basic/playerstats/1/28",
  "scheme"="https",
  "Accept" = "application/json, text/plain, */*",
  "Accept-Encoding" = "gzip, deflate, br, zstd",
  "Accept-Language" = "es-ES,es;q=0.9,en;q=0.8",
  "Authorization" = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjZWI4ZWMyNjQzN2Q0MGEwODI5NDVmYjJiYTgzMmIwYyIsInN1YiI6IjE1MDkwIiwic2NvcGUiOlsiYmFzaWMiXSwiZXhwIjoxNzYxODE2NTQxfQ.fZwk-GyWXoaQnW_5w72JGpwOXIEztB1snXAzq7gmYdE",
  "Cache-Control" = "no-cache",
  "Pragma" = "no-cache",
  "Referer" = "https://supermanager.acb.com/market?position=1",
  "Sec-Ch-Ua" = "\"Not/A)Brand\";v=\"8\", \"Chromium\";v=\"126\", \"Google Chrome\";v=\"126\"",
  "Sec-Ch-Ua-Mobile" = "?0",
  "Sec-Ch-Ua-Platform" = "\"macOS\"",
  "Sec-Fetch-Dest" = "empty",
  "Sec-Fetch-Mode" = "cors",
  "Sec-Fetch-Site" = "same-origin",
  "User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
)

id <- superManager$idPlayer


players_superM <- function(id) {
  
  urlplayer <- paste0("https://supermanager.acb.com/api/basic/playerstats/1/", id)
  
  response <- GET(urlplayer, add_headers(.headers = headers))
  
  superManager_player <- fromJSON(content(response, "text", encoding = "UTF-8"))
  
  playerDF <- superManager_player %>%
    pluck("playerStats") %>%
    tibble() %>%
    mutate(shortName = superManager_player$shortName,
           nameTeam = superManager_player$nameTeam,
           license = superManager_player$license,
           photo = superManager_player$photo2,
           initialPrice = superManager_player$initialPrice,
           price = superManager_player$price,
           nick = superManager_player$nick,
           idTeam = superManager_player$idTeam,
           number = superManager_player$number,
           idPlayer = superManager_player$idPlayer) %>%
    # Check si la columna playerprice existe
    { if ("playerPrice" %in% colnames(.)) select(., idPlayer, shortName, nick, license, idTeam, nameTeam, playerPrice, initialPrice, price, everything())
      else select(., idPlayer, shortName, nick, license, idTeam, nameTeam, initialPrice, price, everything()) }
  
  return(playerDF)
}

# Map the function over the list of ids
players_superM_Df <- map_df(id, players_superM)

write_csv(players_superM_Df,here::here("2026", "supermanager", "basicos", "datosjugadores", "csv", "players_superM_Df.csv"))
readRDS(here::here("2025", "superManager", "rds", "players_superM_Df.rds")) %>%
  glimpse()


