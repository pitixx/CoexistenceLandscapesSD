source('scripts/LC_1_ReadManipData.R')

carbon_gl_ll_sr <- raster('~/Cloud/OneDrive - United Nations/Data/GeoData/BiomassCarbon/Global Vegetation biomass carbon stocks - 1 km resolution/data/w001001.adf')

carbon_al_ll_sr <- crop(carbon_gl_ll_sr,lc0018_al_ll_sb)

carbon_al_ll_sr_resmp <- projectRaster(carbon_al_ll_sr,lc0018_al_ll_sb)

carbon_al_ll_sr_resmp <- mask(carbon_al_ll_sr_resmp,lut_al_ll_sv)

carbon_al_ns_df <- as.data.frame(zonal(carbon_al_ll_sr_resmp,lc0018_al_ll_sb[[1]],fun='mean'))

carbon_al_ns_df <- merge(carbon_al_ns_df,lcc_simp_ns_tb,by.x="zone",by.y="class")

names(carbon_al_ns_df) <- c("lc_class","kg_C_m2","lc_desc")
carbon_al_ns_df <- carbon_al_ns_df[,c(1,3,2)]

write.csv(carbon_al_ns_df,'output/HKC_CarbonBiomass_2000.csv',row.names = F)

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