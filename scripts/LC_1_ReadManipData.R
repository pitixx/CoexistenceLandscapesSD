source('scripts/pkg_functions.R')

#### Read Data  ####

#read polygon masks ####
mask_bw_ll_sv <- read_sf('data/HKC_BW.gpkg')
mask_zw_ll_sv <- read_sf('data/HKC_ZW.gpkg')
mask_al_ll_sv <- read_sf('data/HKC_bdy.gpkg')
mask_al_ll_sv <- mask_al_ll_sv["WDA"]
# Equal area masks
mask_bw_ea_sv <- st_transform(mask_bw_ll_sv,crs = 102022)
mask_zw_ea_sv <- st_transform(mask_zw_ll_sv,crs = 102022)

#read the admin land use/tenure polygon layer
lut_al_mc_sv <- read_sf('data/HKC_LU.gpkg')

# Recode objectid in our poly layer
lut_al_mc_sv$OBJECTID <- seq(1:length(lut_al_mc_sv$Country))

# Project lut to both ll and ea 
lut_al_ll_sv <- st_transform(lut_al_mc_sv,crs = 4326)
lut_al_ea_sv <- st_transform(lut_al_mc_sv,crs = 102022)

#Add Land Use / Tenure field
lut_al_ea_sv$LUT <- paste(lut_al_ea_sv$Land.Use," (",lut_al_ea_sv$Tenure,")",sep="")

#project to Albers equal area
lut_al_ea_sv <- st_transform(lut_al_ea_sv,crs = 102022)

#oder the table in our polygon land use/tenure layer
lut_al_ea_sv <- lut_al_ea_sv[order(lut_al_ea_sv$Land.Use,lut_al_ea_sv$Tenure),]

# Reclass matrix for land cover
rcm_ns_tb <- matrix(c(10,40,62,122,11,40,110,122,10,30,60,120),ncol=3)

# Land cover type names
lccs_ns_tb <- read.delim('data/lccs_hkc.txt')

lcc_simp_ns_tb <- data.frame("class"=c(10,30,60,120,130,180,190,200,210),"description"=c("Crops rainfed","Crop-tree mosaic", "Woodland","Shrubland","Grassland","Flooded Vegetation","Built areas", "Bare areas", "Water bodies"))

## Land cover for the whole WDA (added 18.05.2020)
lc0018_al_ll_sb <- brick('~/Cloud/OneDrive - United Nations/Data/GeoData/LandCover/ESA/ESACCI-Africa_LC-L4-LCCS-Map-300m-P1Y-1992_2015-v2.0.7.tif')
lc0018_al_ll_sb <- lc0018_al_ll_sb[[9:24]]
lc0018_al_ll_sb <- crop(lc0018_al_ll_sb,lut_al_ll_sv)

lc0018_al_ll_sb <- addLayer(lc0018_al_ll_sb,lc1618_al_ll_sb[[1]])
lc0018_al_ll_sb <- addLayer(lc0018_al_ll_sb,lc1618_al_ll_sb[[2]])
lc0018_al_ll_sb <- addLayer(lc0018_al_ll_sb,lc1618_al_ll_sb[[3]])

names(lc0018_al_ll_sb) <- c(2000:2018)

# 1992-2015 land cover for the BW and ZW components of HKC (prepared earlier in Qgis)
#lc stands for land cover — already in equal area projection

lc9215_zw_ea_sb <- brick('data/HKC_ZW_LC_1992-2015.tif')
lc9215_bw_ea_sb <- brick('data/HKC_BW_LC_1992-2015.tif')

##### Rasterize the polygon Land Use Layer for each country ##### 
# First create an empty raster of the same dimensions
lut_zw_ea_sr <- raster(lc9215_zw_ea_sb[[1]])
lut_bw_ea_sr <- raster(lc9215_bw_ea_sb[[1]])

#Rasterize
lut_zw_ea_sr <- rasterize(lut_al_ea_sv,y = lut_zw_ea_sr,field="OBJECTID")
lut_bw_ea_sr <- rasterize(lut_al_ea_sv,y = lut_bw_ea_sr,field="OBJECTID")

# Mask the rasterized layers
lut_bw_ea_sr <- crop(lut_bw_ea_sr,mask_bw_ea_sv)
lut_bw_ea_sr <- mask(lut_bw_ea_sr,mask_bw_ea_sv)

lut_zw_ea_sr <- crop(lut_zw_ea_sr,mask_zw_ea_sv)
lut_zw_ea_sr <- mask(lut_zw_ea_sr,mask_zw_ea_sv)

# Now we add 2016-18
#Read the land cover rasters 
# Reading from NetCDF4

lc1618_ww_ll_sb <- stack('~/Cloud/OneDrive - United Nations/Data/GeoData/LandCover/ESA/C3S-LC-L4-LCCS-Map-300m-P1Y-2016-v2.1.1.nc',
                 '~/Cloud/OneDrive - United Nations/Data/GeoData/LandCover/ESA/C3S-LC-L4-LCCS-Map-300m-P1Y-2017-v2.1.1.nc',
                 '~/Cloud/OneDrive - United Nations/Data/GeoData/LandCover/ESA/C3S-LC-L4-LCCS-Map-300m-P1Y-2018-v2.1.1.nc',varname="lccs_class")


lc1618_al_ll_sb <- crop(lc1618_ww_ll_sb,lut_al_ll_sv)
lc1618_zw_ll_sb <- crop(lc1618_al_ll_sb,mask_zw_ll_sv)
lc1618_bw_ll_sb <- crop(lc1618_al_ll_sb,mask_bw_ll_sv)

#clip extent zw & bw
lc1618_bw_ll_sb <- mask(lc1618_bw_ll_sb,mask_bw_ll_sv)
lc1618_bw_ll_sb <- crop(lc1618_bw_ll_sb,mask_bw_ll_sv)

lc1618_zw_ll_sb <- mask(lc1618_zw_ll_sb,mask_zw_ll_sv)
lc1618_zw_ll_sb <- crop(lc1618_zw_ll_sb,mask_zw_ll_sv)

#project to Albers Conical Equal Area

lc1618_al_ea_sb <- projectRaster(lc1618_al_ll_sb,crs='+proj=aea +lat_1=20 +lat_2=-23 +lat_0=0 +lon_0=25 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs',method='ngb')

lc1618_bw_ea_sb <- projectRaster(lc1618_bw_ll_sb,lut_bw_ea_sr,method="ngb")
lc1618_zw_ea_sb <- projectRaster(lc1618_zw_ll_sb, lut_zw_ea_sr,method="ngb")

## Add the three latest layers to the main brick
lc9218_zw_ea_sb <- addLayer(lc9215_zw_ea_sb,lc1618_zw_ea_sb)
lc9218_bw_ea_sb <- addLayer(lc9215_bw_ea_sb,lc1618_bw_ea_sb)

## Reclass Bricks to simplify Land Cover

lc9218_zw_ea_sb <- reclassify(lc9218_zw_ea_sb,rcm_ns_tb)
lc9218_bw_ea_sb <- reclassify(lc9218_bw_ea_sb,rcm_ns_tb)

# correct classification of Pandamatenga farms to rainfed crops for all years
panda_v <- lut_al_ea_sv[lut_al_ea_sv$Land.Use=="Commercial Agriculture",9]

bk <- raster('~/Cloud/OneDrive - United Nations/Data/GeoData/LandCover/ESA/C3S-LC-L4-lccs-Map-300m-P1Y-2018-v2.1.1.nc',varname="lccs_class")

bk <- crop(bk,mask_bw_ll_sv)
bk <- mask(bk,mask_bw_ll_sv)
bk <- bk/bk
bk <- projectRaster(bk,lut_bw_ea_sr,method="ngb")
panda_r <- rasterize(panda_v,y = bk, field="OBJECTID")
panda_r <- panda_r*(-1)
panda_r[is.na(panda_r)] <- 1

lc9218_bw_ea_sb <- lc9218_bw_ea_sb*panda_r
lc9218_bw_ea_sb[lc9218_bw_ea_sb<0] <- 10

### Land use/tenure classes table
lut_al_ns_tb <- lut_al_ea_sv[,c(9,10)]
st_geometry(lut_al_ns_tb) <- NULL

lut_al_ns_df <- lut_al_ea_sv[,c(3,9,10,5)]
st_geometry(lut_al_ns_df) <- NULL

### Extent of whole HKC WDA
ext_al_ll_ex <- extent(lut_al_ll_sv)

ext_al_ea_ex <- extent(lut_al_ea_sv)

