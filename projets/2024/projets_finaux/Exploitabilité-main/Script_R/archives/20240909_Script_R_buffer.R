------------------------------------------------------------------------
  
  title: "Test script R -projet"
author: "Killian BAUE"
Contact: "killian.baue@agroparistech.fr"
format: R

df-print: paged
self-contained: true

editor: visual

------------------------------------------------------------------------
  
  # Chargement des librairies ----

library(readxl)
library(happign)
library(tmap)
library(sf)
library(dplyr)
tmap_mode("view")

# Importation des données cadastrales de la zone d'étude ----

nombres <- 1500:1600
vecteur_chaine <- sprintf("%04d", nombres)

Saxel_parca_pci <- get_apicarto_cadastre(
  x = "74261",               
  type = "parcelle",         
  section = "0A",            
  numero = vecteur_chaine,   
  source = "pci",            
  progress = TRUE            
)

qtm(Saxel_parca_pci)

# Re-projeter les données en Lambert 93 ----

Saxel_parca_pci_2154 <- st_transform(Saxel_parca_pci, crs = 2154)

st_write(Saxel_parca_pci_2154, "testRprojet.gpkg", layer = "Saxel_parca_pci_2154", append = TRUE)

st_layers("testRprojet.gpkg")

# Orthophotos et altimétrie ----

IRC_layer_name <- "ORTHOIMAGERY.ORTHOPHOTOS.IRC"
IRC <- get_wms_raster(x = Saxel_parca_pci, layer = IRC_layer_name, res = 10)

tm_shape(IRC) + tm_rgb() + tm_shape(Saxel_parca_pci) + tm_borders(col = 'white')

MNT_layer_name <- "RGEALTI-MNT_PYR-ZIP_FXX_LAMB93_WMS"
MNS_layer_name <- "ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES.MNS"

MNT <- get_wms_raster(x = Saxel_parca_pci, layer = MNT_layer_name, res = 10, rgb = FALSE)
MNS <- get_wms_raster(x = Saxel_parca_pci, layer = MNS_layer_name, res = 10, rgb = FALSE)

MNH <- MNS - MNT
MNH[MNH < 0] <- 0

tmap_mode("view")

qtm(MNH) + tm_raster() + tm_shape(Saxel_parca_pci) + tm_borders(col = 'white')

# Chargement des vecteurs routier et hydrographique ----

routes <- get_wfs(Saxel_parca_pci, "BDTOPO_V3:troncon_de_route", spatial_filter = "intersects")
troncon_hydro <- get_wfs(Saxel_parca_pci, "BDTOPO_V3:troncon_hydrographique", spatial_filter = "intersects")

routes_l93 <- st_transform(routes, crs = 2154)
troncon_hydro_l93 <- st_transform(troncon_hydro, crs = 2154)

tm_shape(Saxel_parca_pci) +
  tm_borders() +
  tm_shape(routes_l93) +
  tm_lines(col = "red", lwd = 1, legend.col.title = "Routes") +
  tm_shape(troncon_hydro_l93) +
  tm_lines(col = "blue", lwd = 1, legend.col.title = "Ruisseaux") +
  tm_layout(legend.outside = TRUE)

# Buffers ----

buffer_60_80m <- st_difference(st_buffer(routes_l93, 80), st_buffer(routes_l93, 60))
buffer_40_60m <- st_difference(st_buffer(routes_l93, 60), st_buffer(routes_l93, 40))
buffer_20_40m <- st_difference(st_buffer(routes_l93, 40), st_buffer(routes_l93, 20))
buffer_0_20m <- st_difference(st_buffer(routes_l93, 20), st_buffer(routes_l93, 0))

buffer_60_80m_sf <- st_sf(geometry = st_geometry(buffer_60_80m), Buffer = "60 à 80 m")
buffer_40_60m_sf <- st_sf(geometry = st_geometry(buffer_40_60m), Buffer = "40 à 60 m")
buffer_20_40m_sf <- st_sf(geometry = st_geometry(buffer_20_40m), Buffer = "20 à 40 m")
buffer_0_20m_sf <- st_sf(geometry = st_geometry(buffer_0_20m), Buffer = "0 à 20 m")

buffers_combined <- rbind(buffer_60_80m_sf, buffer_40_60m_sf, buffer_20_40m_sf, buffer_0_20m_sf)
buffers_combined <- st_make_valid(buffers_combined)

routes_simplified <- st_simplify(routes_l93, dTolerance = 1)

tm_shape(Saxel_parca_pci) +
  tm_borders() +
  tm_shape(buffers_combined) +
  tm_fill(col = "Buffer", 
          palette = c("#FF4500", "#FFA07A", "#87CEEB", "#add8e6"),
          alpha = 0.3, 
          legend.col.title = "Distance") +
  tm_shape(routes_simplified) +
  tm_lines(col = "red", lwd = 2, legend.col.title = "Routes") +
  tm_shape(troncon_hydro_l93) +
  tm_lines(col = "blue", lwd = 2, legend.col.title = "Ruisseaux") +
  tm_layout(legend.outside = TRUE, 
            legend.outside.position = "right",
            legend.title.size = 1.5, 
            legend.text.size = 1.2, 
            legend.bg.color = "white", 
            legend.bg.alpha = 0.8)

# Exportation Geopackage ----

st_write(routes_l93, "pplmt_data.gpkg", layer = "routes", append = TRUE)
st_write(troncon_hydro_l93, "pplmt_data.gpkg", layer = "troncon_hydro", append = TRUE)

writeRaster(IRC, "pplmt_data.gpkg", filetype = "GPKG", gdal = c("APPEND_SUBDATASET=YES", "RASTER_table=IRC"))
writeRaster(MNH, "pplmt_data.gpkg", filetype = "GPKG", gdal = c("APPEND_SUBDATASET=YES", "RASTER_table=MNH"))


# suite
# test 2
####