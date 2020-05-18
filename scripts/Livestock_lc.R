source('scripts/LC_1_ReadManipData.R')

livestock_af_ll_sb <- brick('~/Cloud/OneDrive - United Nations/Data/GeoData/Livestock/FAO/GLW3_2010/AF_Cattle1km_AD_2010_GLW2_01_TIF/AF_Cattle1km_AD_2010_v2_1.tif')
livestock_af_ll_sb <- addLayer(livestock_af_ll_sb,'~/Cloud/OneDrive - United Nations/Data/GeoData/Livestock/FAO/GLW3_2010/AF_Goats1km_AD_2010_v2_1_TIF/AF_Goats1km_AD_2010_v2_1.tif')
livestock_af_ll_sb <- addLayer(livestock_af_ll_sb,'~/Cloud/OneDrive - United Nations/Data/GeoData/Livestock/FAO/GLW3_2010/AF_Sheep1km_AD_2010_GLW2_1_TIF/AF_Sheep1km_AD_2010_v2_1.tif')
livestock_af_ll_sb <- addLayer(livestock_af_ll_sb,'~/Cloud/OneDrive - United Nations/Data/GeoData/Livestock/FAO/GLW3_2010/AF_TLU_Ruminants/AF_TLU_ruminants.tif')


names(livestock_af_ll_sb) <- c("cattle","goats","sheep","tlu")

# # Crop livestock to WDA
livestock_al_ll_sb <- crop(livestock_af_ll_sb,mask_al_ll_sv)
<<<<<<< HEAD
# mask (not needed?)
=======
# 
>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0
livestock_al_ll_sb <- mask(livestock_al_ll_sb,mask_al_ll_sv)

# Project country land covers to ll 
lc9218_bw_ll_sb <- projectRaster(lc9218_bw_ea_sb,lc1618_bw_ll_sb,method = 'ngb')
lc9218_zw_ll_sb <- projectRaster(lc9218_zw_ea_sb,lc1618_zw_ll_sb,method = 'ngb')


# Calculate livestock for Botswana
lstock_bw_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = livestock_al_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_bw_ll_sv,
  lcmask_al_ll_rx = lc9218_bw_ll_sb
)

livestock_bw_ns_df <- Xtract_byLC(
  lstock_bw_ll_sb,
  lc9218_bw_ll_sb[[19]],
  "lstock",
  "BW",
  "sum")

<<<<<<< HEAD
livestock_bw_ns_df <- clean_mylstock_data(livestock_bw_ns_df)
=======
>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0

# Calculate livestock for Zimbabwe
lstock_zw_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = livestock_al_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_zw_ll_sv,
  lcmask_al_ll_rx = lc1618_zw_ll_sb
)

livestock_zw_ns_df <- Xtract_byLC(
  lstock_zw_ll_sb,
  lc1618_zw_ll_sb[[3]],
  "lstock",
  "ZW",
  "sum")

<<<<<<< HEAD
livestock_zw_ns_df <- clean_mylstock_data(livestock_zw_ns_df)

livestock_al_ns_df <- rbind(livestock_bw_ns_df,livestock_zw_ns_df)


write.csv(livestock_al_ns_df,file='output/livestock_by_LC_2010.csv',row.names = F)
=======




# Crop livestock to BW and ZW
livestock_bw_ll_sb <- crop(livestock_al_ll_sb,mask_bw_ll_sv)
livestock_bw_ll_sb <- mask(livestock_bw_ll_sb,mask_bw_ll_sv)

# # Rasterize lut_al_ea_sv
# 
# lut_al_ea_sv_al_ll_sr <- rasterize(x=lut_al_ea_sv,y=livestock_al_ll_sb,field="OBJECTID")

# lut_al_ea_sv_al_ea_sr <- projectRaster(lut_al_ea_sv_al_ll_sr,crs='+proj=aea +lat_1=20 +lat_2=-23 +lat_0=0 +lon_0=25 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs',method='ngb')


livestock_count_2010_df <- as.data.frame(zonal(livestock_bw_ll_sb,lc_bw_92_18[[19]],fun='sum'))

names(livestock_count_2010_df) <- c("OBJECTID","Cattle","Goats","Sheep","Small_Rumin_TLU")

livestock_count_2010_df <- merge(livestock_count_2010_df,lut_al_df,by='OBJECTID')

livestock_count_2010_df <- livestock_count_2010_df[,c(6,7,8,2,3,4,5)]

livestock_count_2010_df <- aggregate(livestock_count_2010_df[,c(3:7)],by=list(livestock_count_2010_df$Country,livestock_count_2010_df$LUT),FUN=sum)

names(livestock_count_2010_df) <- c("Country", "LUT","area_km2","cattle","goats","sheep","small_rumin_TLU")
livestock_count_2010_df$Country <-  ifelse(livestock_count_2010_df$Country=="Zimbabwe","ZW","BW")

livestock_count_2010_df <- livestock_count_2010_df[order(livestock_count_2010_df$Country, livestock_count_2010_df$LUT),]

write.csv(livestock_count_2010_df,file='output/livestock_by_LUT_2010.csv',row.names = F)
>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0
