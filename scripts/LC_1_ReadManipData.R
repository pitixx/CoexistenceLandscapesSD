source('scripts/pkg_functions.R')

#### Read Data  ####

#read polygon masks ####
mask_bw <- read_sf('data/HKC_BW.gpkg')
mask_zw <- read_sf('data/HKC_ZW.gpkg')

#read the admin land use/tenure polygon layer
alu <- read_sf('data/HKC_LU.gpkg')

#project to Albers equal area
alu_ea <- st_transform(alu,crs = 102022)

#oder the table in our polygon land use/tenure layer
alu_ea <- alu_ea[order(alu_ea$Land.Use,alu_ea$Tenure),]

# Recode objectid in our poly layer
alu_ea$OBJECTID <- seq(1:length(alu_ea$Country))

# Reclass matrix for land cover
rcm <- matrix(c(10,40,62,122,11,40,110,122,10,30,60,120),ncol=3)

# Land cover type names
lccs <- read.delim('data/lccs_hkc.txt')

slcc <- data.frame("class"=c(10,30,60,120,130,180,190,200,210),"description"=c("Crops rainfed","Crop-tree mosaic", "Woodland","Shrubland","Grassland","Flooded Vegetation","Built areas", "Bare areas", "Water bodies"))


# 1992-2015 land cover for the BW and ZW componwents of HKC (prepared earlier in Qgis)
#lc stands for land cover

lc_zw_92_15 <- brick('data/HKC_ZW_LC_1992-2015.tif')
lc_bw_92_15 <- brick('data/HKC_BW_LC_1992-2015.tif')


##### Rasterize the polygon Land Use Layer ##### 
# First create an empty raster of the same dimensions
lut_ras_zw <- raster(lc_zw_92_15[[1]])
lut_ras_bw <- raster(lc_bw_92_15[[1]])

#Rasterize
lut_ras_zw <- rasterize(alu_ea,y = lut_ras_zw,field="OBJECTID")
lut_ras_bw <- rasterize(alu_ea,y = lut_ras_bw,field="OBJECTID")

# Now we add 2016-18
#Read the land cover rasters 
# Reading from NetCDF4

lc16_18 <- stack('~/Cloud/OneDrive - United Nations/Data/GeoData/LandCover/ESA/C3S-LC-L4-LCCS-Map-300m-P1Y-2016-v2.1.1.nc',
                 '~/Cloud/OneDrive - United Nations/Data/GeoData/LandCover/ESA/C3S-LC-L4-LCCS-Map-300m-P1Y-2017-v2.1.1.nc',
                 '~/Cloud/OneDrive - United Nations/Data/GeoData/LandCover/ESA/C3S-LC-L4-LCCS-Map-300m-P1Y-2018-v2.1.1.nc',varname="lccs_class")

lc16_18zw <- crop(lc16_18,mask_zw)
lc16_18bw <- crop(lc16_18,mask_bw)

#clip extent zw & bw
lc16_18bw <- mask(lc16_18bw,mask_bw)
lc16_18bw <- crop(lc16_18bw,mask_bw)

lc16_18zw <- mask(lc16_18zw,mask_zw)
lc16_18zw <- crop(lc16_18zw,mask_zw)

#project to Albers Conical Equal Area
lc16_18bw <- projectRaster(lc16_18bw,lut_ras_bw,method="ngb")
lc16_18zw <- projectRaster(lc16_18zw,lut_ras_zw,method="ngb")

## Add the three latest layers to the main brick
lc_zw_92_18 <- addLayer(lc_zw_92_15,lc16_18zw)
lc_bw_92_18 <- addLayer(lc_bw_92_15,lc16_18bw)

## Reclass Bricks to simplify Land Cover

lc_zw_92_18 <- reclassify(lc_zw_92_18,rcm)
lc_bw_92_18 <- reclassify(lc_bw_92_18,rcm)

# correct classification of Pandamatenga farms to rainfed crops for all years
panda_v <- alu_ea[alu_ea$Land.Use=="Commercial Agriculture",9]

bk <- raster('~/Cloud/OneDrive - United Nations/Data/GeoData/LandCover/ESA/C3S-LC-L4-LCCS-Map-300m-P1Y-2018-v2.1.1.nc',varname="lccs_class")

bk <- crop(bk,mask_bw)
bk <- mask(bk,mask_bw)
bk <- bk/bk
bk <- projectRaster(bk,lut_ras_bw,method="ngb")
panda_r <- rasterize(panda_v,y = bk, field="OBJECTID")
panda_r <- panda_r*(-1)
panda_r[is.na(panda_r)] <- 1

lc_bw_92_18 <- panda_r*lc_bw_92_18
lc_bw_92_18[lc_bw_92_18<0] <- 10

