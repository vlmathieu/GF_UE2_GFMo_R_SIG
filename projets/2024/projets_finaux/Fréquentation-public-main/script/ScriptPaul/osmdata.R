library(osmdata)
devtools::install_github("paul-carteron/happign")
# https://wiki.openstreetmap.org/wiki/Map_features

# Define the area of interest and query for parking
nancy <- get_apicarto_cadastre("54395", type = "commune") |>
  st_transform(4326) |>
  st_bbox()

query <- opq(bbox = nancy) |>
  add_osm_feature(key = 'amenity', value = c('bar','pub'))

# Retrieve the data
osm_bar <- osmdata_sf(query)

# View the parking locations as an sf object
bar_sf <- osm_bar$osm_points


qtm(bar_sf)
plot(parking_sf)

View(cog_2023)
