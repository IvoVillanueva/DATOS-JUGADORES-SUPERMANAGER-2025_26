
# librerias
library(jsonlite)
library(tidyverse)
library(httr)


# asegurar que la carpeta data existe
if (!dir.exists("data")) dir.create("data")

# cabeceras
headers <- c(
  "Authorization" = Sys.getenv("SM_TOKEN"),
  "Accept" = "application/json"
)

# Cargar datos desde la API con cabeceras personalizadas
superManager <- 
  fromJSON(
    content(
      GET(
        url = Sys.getenv("URL_SUPERMANAGER"),
        add_headers(.headers = headers)
      ),
      "text",
      encoding = "UTF-8"
    ),
    flatten = TRUE
  ) %>%
  # Expandir columnas anidadas de estadísticas de jugador
  unnest_wider(playerStats) %>%
  # Crear la URL completa del logo del equipo
  mutate(
    imageTeamNegative = paste0(
      "https://supermanager.acb.com/files/logo/",
      imageTeamNegative
    )
  )

# guardarlo en csv
write.csv(superManager, "data/supermanager_juagadores_2026.csv")

#funcion estadisticas por jugador
players_superM <- function(id) {
  
  superManager_player <- fromJSON(content(GET(paste0(Sys.getenv("URL_PLAYERS"), id),
                                              add_headers(.headers = headers)),
                                          "text", encoding = "UTF-8"))
  
  playerDF <- superManager_player %>%
    pluck("playerStats") %>%
    tibble() %>%
    mutate(
      shortName = superManager_player$shortName,
      nameTeam = superManager_player$nameTeam,
      license = superManager_player$license,
      photo = superManager_player$photo2,
      initialPrice = superManager_player$initialPrice,
      price = superManager_player$price,
      nick = superManager_player$nick,
      idTeam = superManager_player$idTeam,
      number = superManager_player$number,
      idPlayer = superManager_player$idPlayer 
    ) %>%
    filter(numberJourney != max(numberJourney)) %>% 
    select(idPlayer, shortName, nick, license, idTeam, nameTeam, playerPrice, initialPrice, price, everything()) %>%
    select(where(~ !all(is.na(.x))))
 
  return(playerDF)
}

# Map the function over the list of ids
players_superM_Df <- map_df(superManager$idPlayer, players_superM)


write.csv(players_superM_Df,"data/supermanager_juagadores_stats_2026.csv")


