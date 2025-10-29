
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
# sacar datos de jugadores
super_manager <- fromJSON(txt = content(
  GET(
    url = Sys.getenv("URL_SUPERMANAGER"),
    add_headers(.headers = headers),
    flatten = TRUE
  ),
  "text",
  encoding = "UTF-8"
)) %>%
  unnest_wider(playerStats) %>%
  mutate(imageTeamNegative = paste0("https://supermanager.acb.com/files/logo/", imageTeamNegative))

# guardarlo en csv
write.csv(superManager, "data/supermanager_juagadores_2026.csv")






