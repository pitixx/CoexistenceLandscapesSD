source('scripts/pkg_functions.R')

#### PRECIPITATION ####

rain <- stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Precipitation/pr_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_199101-200012.nc')
rain <- addLayer(rain, 
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Precipitation/pr_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_200101-200512.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Precipitation/pr_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_200601-201012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Precipitation/pr_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_201101-202012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Precipitation/pr_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_202101-203012.nc'))

rain <- brick(rain)

r_bw <- Xtract(rain,mask_bw,"rain","BW")
r_zw <- Xtract(rain,mask_zw,"rain","ZW")
climate <- rbind(r_bw,r_zw) 
climate$date <- as.Date(climate$date)
climate$rain <- climate$rain*days_in_month(climate$date)*24*60*60

#### TEMPERATURE #####
temp <- stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/NearSurfaceTemp/tas_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_199101-200012.nc')
temp <- addLayer(temp,
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/NearSurfaceTemp/tas_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_200101-200512.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/NearSurfaceTemp/tas_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_200601-201012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/NearSurfaceTemp/tas_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_201101-202012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/NearSurfaceTemp/tas_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_202101-203012.nc')
                 )
temp <- brick(temp)

t_bw <- Xtract(temp,mask_bw,"temperature","BW")
t_zw <- Xtract(temp,mask_zw,"temperature","ZW")
temperature <- rbind(t_bw,t_zw)
climate$temperature <- temperature$temperature-273

##### EVAPORATION ####

evap <- stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Evaporation/evspsbl_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_199101-200012.nc')
evap <- addLayer(evap, 
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Evaporation/evspsbl_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_200101-200512.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Evaporation/evspsbl_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_200601-201012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Evaporation/evspsbl_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_201101-202012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/Evaporation/evspsbl_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_202101-203012.nc')
                 )
evap <- brick(evap)

e_bw <- Xtract(evap,mask_bw,"evaporation","BW")
e_zw <- Xtract(evap,mask_zw,"evaporation","ZW")
evaporation <- rbind(e_bw,e_zw)
climate$evaporation <- evaporation$evaporation*days_in_month(climate$date)*24*60*60

##### TOTAL RUNOFF ####
roff <- stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/TotalRunoff/mrro_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_199101-200012.nc')
roff <- addLayer(roff,
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/TotalRunoff/mrro_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_200101-200512.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/TotalRunoff/mrro_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_200601-201012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/TotalRunoff/mrro_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_201101-202012.nc'),
                 stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/TotalRunoff/mrro_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_202101-203012.nc'))
roff <- brick(roff)

o_bw <- Xtract(roff,mask_bw,"total_runoff","BW")
o_zw <- Xtract(roff,mask_zw,"total_runoff","ZW")

runoff <- rbind(o_bw,o_zw)
climate$total_runoff <- runoff$total_runoff*days_in_month(climate$date)*24*60*60 


#SOIL MOISTURE CONTENT
smc <- stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/SoilMoistureContent/mrso_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_199101-200012.nc')
smc <- addLayer(smc,
                stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/SoilMoistureContent/mrso_AFR-22_CCCma-CanESM2_historical_r1i1p1_CCCma-CanRCM4_r2_mon_200101-200512.nc'),
                stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/SoilMoistureContent/mrso_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_200601-201012.nc'),
                stack('~/Cloud/OneDrive - United Nations/Data/GeoData/Climate/ClimateScenarios/CanRCM4/SoilMoistureContent/mrso_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_201101-202012.nc'),
                stack('CanRCM4/SoilMoistureContent/mrso_AFR-22_CCCma-CanESM2_rcp45_r1i1p1_CCCma-CanRCM4_r2_mon_202101-203012.nc'))
smc <- brick(smc)

m_bw <- Xtract(smc,mask_bw,"soil_moist","BW")
m_zw <- Xtract(smc,mask_zw,"soil_moist","ZW")

soilmoist <- rbind(m_bw,m_zw)
climate <- merge(climate,soilmoist,by=c("country","date"))


write.csv(x = climate,file='output/HKC_climate_CanRCM4_1991-2030.csv',row.names = F)


