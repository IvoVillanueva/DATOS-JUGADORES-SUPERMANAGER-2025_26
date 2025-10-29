
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
        url = "https://supermanager.acb.com/api/basic/player?_filters=%5B%7B%22field%22:%22competition.idCompetition%22,%22value%22:1,%22operator%22:%22=%22,%22condition%22:%22AND%22%7D,%7B%22field%22:%22edition.isActive%22,%22value%22:true,%22operator%22:%22=%22,%22condition%22:%22AND%22%7D%5D&_page=1&_perPage=30&_sort=%5B%7B%22field%22:%22price%22,%22type%22:%22DESC%22%7D%5D",
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






