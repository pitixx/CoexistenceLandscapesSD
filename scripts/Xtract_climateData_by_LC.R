source('scripts/LC_1_ReadManipData.R')

## This file calculates mean monthly averages of climate variables by land cover class, assuming land cover of 2018 unchanged back in time to 1992

#### PRECIPITATION ####
# read rain ####
rain_ww_ll_ss <- stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Precipitation/pr_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_199101-200012.nc')
rain_ww_ll_ss <- addLayer(rain_ww_ll_ss, 
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Precipitation/pr_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_200101-200512.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Precipitation/pr_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_200601-201012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Precipitation/pr_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_201101-202012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Precipitation/pr_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_202101-203012.nc'))

rain_ww_ll_sb <- brick(rain_ww_ll_ss)
crs(rain_ww_ll_sb) <- '+proj=longlat +datum=WGS84 +no_defs'

# Prepare and extract rain for BW and ZW ####

rain_bw_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = rain_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_bw_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
  )

rainxlc_bw_ns_df <- Xtract_byLC(rain_bw_ll_sb,lc1618_bw_ll_sb[[3]],"rain_lm2","BW","mean")
<<<<<<< HEAD
rainxlc_bw_ns_df <- clean_myclim_data(rainxlc_bw_ns_df,"rain")
=======
>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0

# Zimbabwe
rain_zw_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = rain_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_zw_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

rainxlc_zw_ns_df <- Xtract_byLC(rain_zw_ll_sb,lc1618_zw_ll_sb[[3]],"rain_lm2","ZW","mean")
<<<<<<< HEAD
rainxlc_zw_ns_df <- clean_myclim_data(rainxlc_zw_ns_df,"rain")
=======
>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0

# Combine rain data and do conversions for total monthly rain. ####
rainxlc_al_ns_df <- rbind(rainxlc_bw_ns_df,rainxlc_zw_ns_df)
rainxlc_al_ns_df$date <- as.Date(rainxlc_al_ns_df$date)
rainxlc_al_ns_df$rain_lm2 <- rainxlc_al_ns_df$rain_lm2*days_in_month(rainxlc_al_ns_df$date)*24*60*60

# Assign to climate data frame, to which we'll add temp, soil moist, etc. 
climate_al_ns_df <- rainxlc_al_ns_df

#### TEMPERATURE #####
temp_ww_ll_ss <- stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/NearSurfaceTemp/tas_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_199101-200012.nc')
temp_ww_ll_ss <- addLayer(temp_ww_ll_ss,
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/NearSurfaceTemp/tas_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_200101-200512.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/NearSurfaceTemp/tas_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_200601-201012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/NearSurfaceTemp/tas_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_201101-202012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/NearSurfaceTemp/tas_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_202101-203012.nc')
                 )
temp_ww_ll_sb <- brick(temp_ww_ll_ss)
crs(temp_ww_ll_sb) <- '+proj=longlat +datum=WGS84 +no_defs'

# Temp BW
temp_bw_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = temp_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_bw_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

tempxlc_bw_ns_df <- Xtract_byLC(temp_bw_ll_sb,lc1618_bw_ll_sb[[3]],"temp","BW","mean")
<<<<<<< HEAD
tempxlc_bw_ns_df <- clean_myclim_data(tempxlc_bw_ns_df,"temp")
=======

>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0

# Zimbabwe
temp_zw_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = temp_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_zw_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

# Clean convert assign

tempxlc_zw_ns_df <- Xtract_byLC(temp_zw_ll_sb,lc1618_zw_ll_sb[[3]],"temp","ZW","mean")
<<<<<<< HEAD
tempxlc_zw_ns_df <- clean_myclim_data(tempxlc_zw_ns_df,"temp")

=======
>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0

tempxlc_al_ns_df <- rbind(tempxlc_bw_ns_df,tempxlc_zw_ns_df)
tempxlc_al_ns_df$temp <- tempxlc_al_ns_df$temp-273

climate_al_ns_df$temp_mth_mean_C <- tempxlc_al_ns_df$temp

##### EVAPORATION ####

evap_ww_ll_ss <- stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Evaporation/evspsbl_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_199101-200012.nc')
evap_ww_ll_ss <- addLayer(evap_ww_ll_ss, 
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Evaporation/evspsbl_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_200101-200512.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Evaporation/evspsbl_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_200601-201012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Evaporation/evspsbl_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_201101-202012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Evaporation/evspsbl_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_202101-203012.nc')
                 )
evap_ww_ll_sb <- brick(evap_ww_ll_ss)
crs(evap_ww_ll_sb) <- '+proj=longlat +datum=WGS84 +no_defs'

#Evap BW
evap_bw_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = evap_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_bw_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

evapxlc_bw_ns_df <- Xtract_byLC(evap_bw_ll_sb,lc1618_bw_ll_sb[[3]],"evap","BW","mean")
<<<<<<< HEAD
evapxlc_bw_ns_df <- clean_myclim_data(evapxlc_bw_ns_df,"evap")
=======
>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0

# Evap Zimbabwe
evap_zw_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = evap_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_zw_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

evapxlc_zw_ns_df <- Xtract_byLC(evap_zw_ll_sb,lc1618_zw_ll_sb[[3]],"evap","ZW","mean")
<<<<<<< HEAD
evapxlc_zw_ns_df <- clean_myclim_data(evapxlc_zw_ns_df,"evap")
=======
>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0

evapxlc_al_ns_df <- rbind(evapxlc_bw_ns_df,evapxlc_zw_ns_df)
evapxlc_al_ns_df$date <- as.Date(evapxlc_al_ns_df$date)
evapxlc_al_ns_df$evap <- evapxlc_al_ns_df$evap*days_in_month(evapxlc_al_ns_df$date)*24*60*60

climate_al_ns_df$evap_lm2<- evapxlc_al_ns_df$evap

##### TOTAL RUNOFF ####
roff_ww_ll_ss <- stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/TotalRunoff/mrro_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_199101-200012.nc')
roff_ww_ll_ss <- addLayer(roff_ww_ll_ss,
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/TotalRunoff/mrro_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_200101-200512.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/TotalRunoff/mrro_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_200601-201012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/TotalRunoff/mrro_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_201101-202012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/TotalRunoff/mrro_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_202101-203012.nc'))
roff_ww_ll_sb <- brick(roff_ww_ll_ss)
rm(roff_ww_ll_ss)

crs(roff_ww_ll_sb) <- '+proj=longlat +datum=WGS84 +no_defs'


#roff BW
roff_bw_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = roff_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_bw_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

roffxlc_bw_ns_df <- Xtract_byLC(roff_bw_ll_sb,lc1618_bw_ll_sb[[3]],"roff","BW","mean")
<<<<<<< HEAD
roffxlc_bw_ns_df <- clean_myclim_data(roffxlc_bw_ns_df,"roff")
=======

>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0

# roff Zimbabwe
roff_zw_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = roff_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_zw_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

roffxlc_zw_ns_df <- Xtract_byLC(roff_zw_ll_sb,lc1618_zw_ll_sb[[3]],"roff","ZW","mean")
<<<<<<< HEAD
roffxlc_zw_ns_df <- clean_myclim_data(roffxlc_zw_ns_df,"roff")
=======
>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0

roffxlc_al_ns_df <- rbind(roffxlc_bw_ns_df,roffxlc_zw_ns_df)
roffxlc_al_ns_df$date <- as.Date(roffxlc_al_ns_df$date)
roffxlc_al_ns_df$roff <- roffxlc_al_ns_df$roff*days_in_month(roffxlc_al_ns_df$date)*24*60*60

climate_al_ns_df$roff_lm2 <- roffxlc_al_ns_df$roff


#### SOIL MOISTURE CONTENT ####
smc_ww_ll_ss <- stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/SoilMoistureContent/mrso_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_199101-200012.nc')
smc_ww_ll_ss <- addLayer(smc_ww_ll_ss,
                         stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/SoilMoistureContent/mrso_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_200101-200512.nc'),
                         stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/SoilMoistureContent/mrso_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_200601-201012.nc'),
                         stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/SoilMoistureContent/mrso_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_201101-202012.nc'),
                         stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/SoilMoistureContent/mrso_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_202101-203012.nc'))
smc_ww_ll_sb <- brick(smc_ww_ll_ss)
crs(smc_ww_ll_sb) <- '+proj=longlat +datum=WGS84 +no_defs'

#smc BW
smc_bw_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = smc_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_bw_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

<<<<<<< HEAD
smcxlc_bw_ns_df <- Xtract_byLC(smc_bw_ll_sb,lc1618_bw_ll_sb[[3]],"BW","mean")
smcxlc_bw_ns_df <- clean_myclim_data(smcxlc_bw_ns_df,"smc")
=======
smcxlc_bw_ns_df <- Xtract_byLC(smc_bw_ll_sb,lc1618_bw_ll_sb[[3]],"smc","BW","mean")
>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0

# smc Zimbabwe
smc_zw_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = smc_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_zw_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

<<<<<<< HEAD
smcxlc_zw_ns_df <- Xtract_byLC(smc_zw_ll_sb,lc1618_zw_ll_sb[[3]],"ZW","mean")
smcxlc_zw_ns_df <- clean_myclim_data(smcxlc_zw_ns_df,"smc")
=======
smcxlc_zw_ns_df <- Xtract_byLC(smc_zw_ll_sb,lc1618_zw_ll_sb[[3]],"smc","ZW","mean")
>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0

smcxlc_al_ns_df <- rbind(smcxlc_bw_ns_df,smcxlc_zw_ns_df)

climate_al_ns_df$smc_lm2 <- smcxlc_al_ns_df$smc

climate_al_ns_df <- climate_al_ns_df[order(climate_al_ns_df$date,climate_al_ns_df$lc_class,climate_al_ns_df$country),]


write.csv(x = climate_al_ns_df,file='output/HKC_climate_by_LC_CanRCM4_1991-2030.csv',row.names = F)


#### Climate data for entire WDA ####

## Rain
rain_res_al_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = rain_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_al_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

<<<<<<< HEAD
rainxlc_al_ns_df <- Xtract_byLC(
  data_raster = rain_res_al_ll_sb,
  zones_raster = lc1618_al_ll_sb[[3]],
  country = "ALL",
  func = "mean")

rainxlc_al_ns_df <- clean_myclim_data(y = rainxlc_al_ns_df,var="rain")


## Temp

temp_res_al_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = temp_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_al_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

tempxlc_al_ns_df <- Xtract_byLC(temp_res_al_ll_sb,lc1618_al_ll_sb[[3]],"ALL","mean")
tempxlc_al_ns_df <- clean_myclim_data(tempxlc_al_ns_df,"temp")

## Evap

evap_res_al_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = evap_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_al_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

evapxlc_al_ns_df <- Xtract_byLC(evap_res_al_ll_sb,lc1618_al_ll_sb[[3]],"ALL","mean")
evapxlc_al_ns_df <- clean_myclim_data(evapxlc_al_ns_df,"evap")


## Runoff
roff_res_al_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = roff_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_al_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

roffxlc_al_ns_df <- Xtract_byLC(roff_res_al_ll_sb,lc1618_al_ll_sb[[3]],"ALL","mean")
roffxlc_al_ns_df <- clean_myclim_data(roffxlc_al_ns_df,"roff")


### Soil Moisture Content smc

smc_res_al_ll_sb <- resamp_crop_transf(
  data_ww_ll_sx = smc_ww_ll_sb,
  mask_al_ll_sv = lut_al_ll_sv,
  mask_1c_ll_sv = mask_al_ll_sv,
  lcmask_al_ll_rx = lc1618_al_ll_sb,
  method='ngb'
)

smcxlc_al_ns_df <- Xtract_byLC(smc_res_al_ll_sb,lc1618_al_ll_sb[[3]],"ALL","mean")
smcxlc_al_ns_df <- clean_myclim_data(smcxlc_al_ns_df,"smc")


climate_bz_ns_df <- cbind(rainxlc_al_ns_df,tempxlc_al_ns_df$temp,evapxlc_al_ns_df$evap,roffxlc_al_ns_df$roff,smcxlc_al_ns_df$smc)
colnames(climate_bz_ns_df) <- c("country", "date","lc_class","lc_desc","rain_lm2","temp_C","evap_lm2","roff_lm2","smc_lm2")

climate_bz_ns_df$date <- as.Date(climate_bz_ns_df$date)

climate_bz_ns_df$rain_lm2 <- climate_bz_ns_df$rain_lm2*days_in_month(climate_bz_ns_df$date)*24*60*60
climate_bz_ns_df$temp_C <- climate_bz_ns_df$temp_C-273
climate_bz_ns_df$evap_lm2 <- climate_bz_ns_df$evap*days_in_month(climate_bz_ns_df$date)*24*60*60
climate_bz_ns_df$roff_lm2 <- climate_bz_ns_df$roff*days_in_month(climate_bz_ns_df$date)*24*60*60

climate_bz_ns_df <- climate_bz_ns_df[order(climate_bz_ns_df$date,climate_bz_ns_df$lc_class,climate_bz_ns_df$country),]

write.csv(climate_bz_ns_df,file = 'output/HKC_WDA_Agg_climate_by_LC_CanRCM4_1991-2030.csv',row.names = F)
=======
rainxlc_bw_ns_df <- Xtract_byLC(rain_bw_ll_sb,lc1618_bw_ll_sb[[3]],"rain_lm2","BW","mean")

>>>>>>> e8be2a6abd8ac2094994eb5d79eec772e9dd70a0
