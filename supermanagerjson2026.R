
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
