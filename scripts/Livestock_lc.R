source('scripts/LC_1_ReadManipData.R')

livestock_af_ll_sb <- brick('~/Cloud/OneDrive - United Nations/Data/GeoData/Livestock/FAO/GLW3_2010/AF_Cattle1km_AD_2010_GLW2_01_TIF/AF_Cattle1km_AD_2010_v2_1.tif')
livestock_af_ll_sb <- addLayer(livestock_af_ll_sb,'~/Cloud/OneDrive - United Nations/Data/GeoData/Livestock/FAO/GLW3_2010/AF_Goats1km_AD_2010_v2_1_TIF/AF_Goats1km_AD_2010_v2_1.tif')
livestock_af_ll_sb <- addLayer(livestock_af_ll_sb,'~/Cloud/OneDrive - United Nations/Data/GeoData/Livestock/FAO/GLW3_2010/AF_Sheep1km_AD_2010_GLW2_1_TIF/AF_Sheep1km_AD_2010_v2_1.tif')
livestock_af_ll_sb <- addLayer(livestock_af_ll_sb,'~/Cloud/OneDrive - United Nations/Data/GeoData/Livestock/FAO/GLW3_2010/AF_TLU_Ruminants/AF_TLU_ruminants.tif')


names(livestock_af_ll_sb) <- c("cattle","goats","sheep","tlu")

# # Crop livestock to WDA
livestock_al_ll_sb <- crop(livestock_af_ll_sb,mask_al_ll_sv)
# mask (not needed?)
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

livestock_bw_ns_df <- clean_mylstock_data(livestock_bw_ns_df)

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

livestock_zw_ns_df <- clean_mylstock_data(livestock_zw_ns_df)

livestock_al_ns_df <- rbind(livestock_bw_ns_df,livestock_zw_ns_df)


write.csv(livestock_al_ns_df,file='output/livestock_by_LC_2010.csv',row.names = F)
