source('scripts/pkg_functions.R')

#### Read Data — Move this block to its own file so we can source it ####

# 1992-2015 land cover for the BW and ZW componwents of HKC (prepared earlier in Qgis)
#lc stands for land cover

lc_zw_92_15 <- brick('data/HKC_ZW_LC_1992-2015.tif')
lc_bw_92_15 <- brick('data/HKC_BW_LC_1992-2015.tif')


#Now we rasterize the polygon layer
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
                 '~/Cloud/OneDrive - United Nations/Data/GeoData/LandCover/ESA/C3S-LC-L4-LCCS-Map-300m-P1Y-2018-v2.1.1.nc')

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

#TO DO: correct classification of Pandamatenga farms 


