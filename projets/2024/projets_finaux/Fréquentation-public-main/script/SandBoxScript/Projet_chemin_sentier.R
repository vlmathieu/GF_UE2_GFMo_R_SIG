library(happign)
library(tmap);ttm()
library(osmdata)
library(sf)

layers_topo <- get_layers_metadata("wfs","topographie")

point_foret <- mapedit::drawFeatures()

surface_foret <- get_wfs( x = point_foret,
                                      layer ="BDTOPO_V3:foret_publique")

troncons <- get_wfs( x = surface_foret,
                     layer = "BDTOPO_V3:troncon_de_route",
                     spatial_filter = "intersects")

sentier_foret <- troncons[troncons$nature %in% c("Sentier", "Chemin"), ]


qtm(sentier_foret)
