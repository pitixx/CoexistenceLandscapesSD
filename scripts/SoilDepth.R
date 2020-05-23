source('scripts/LC_1_ReadManipData.R')

soil_sediment_depth <- raster('~/Cloud/OneDrive - United Nations/Data/GeoData/Soils/SoilDepth_ORNL/KAZA_HKC_SoilDepth/Avg_SoilDepth+SedDeposit_HKC_1304_1_20200520_140945984.tif')
SoilDepth <- Carbon_Process(soil_sediment_depth)


names(SoilDepth) <- c("lc_class","lc_desc","depth_m")

write.csv(SoilDepth,'output/HKC_Soil_sediment_depth.csv',row.names = F)

# 
# livestock_count_2010_df <- merge(livestock_count_2010_df,lut_al_df,by='OBJECTID')
# 
# livestock_count_2010_df <- livestock_count_2010_df[,c(6,7,8,2,3,4,5)]
# 
# livestock_count_2010_df <- aggregate(livestock_count_2010_df[,c(3:7)],by=list(livestock_count_2010_df$Country,livestock_count_2010_df$LUT),FUN=sum)
# 
# names(livestock_count_2010_df) <- c("Country", "LUT","area_km2","cattle","goats","sheep","small_rumin_TLU")
# livestock_count_2010_df$Country <-  ifelse(livestock_count_2010_df$Country=="Zimbabwe","ZW","BW")
# 
# livestock_count_2010_df <- livestock_count_2010_df[order(livestock_count_2010_df$Country, livestock_count_2010_df$LUT),]
# 
# write.csv(livestock_count_2010_df,file='output/livestock_by_LUT_2010.csv',row.names = F)