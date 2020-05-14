source('scripts/LC_1_ReadManipData.R')

carbon_gl_ll_sr <- raster('~/Desktop/sandbox/Global Vegetation biomass carbon stocks - 1 km resolution/data/w001001.adf')

carbon_al_ll_sr <- crop(carbon_gl_ll_sr,lc1618_al_ll_sb)
carbon_al_ll_sr <- mask(carbon_al_ll_sr,lut_al_ea_sv)


carbon_al_df <- as.data.frame(zonal(carbon_al_ll_sr,alu_al_ll_sr,fun='mean'))

livestock_count_2010_df <- merge(livestock_count_2010_df,lut_al_df,by='OBJECTID')

livestock_count_2010_df <- livestock_count_2010_df[,c(6,7,8,2,3,4,5)]

livestock_count_2010_df <- aggregate(livestock_count_2010_df[,c(3:7)],by=list(livestock_count_2010_df$Country,livestock_count_2010_df$LUT),FUN=sum)

names(livestock_count_2010_df) <- c("Country", "LUT","area_km2","cattle","goats","sheep","small_rumin_TLU")
livestock_count_2010_df$Country <-  ifelse(livestock_count_2010_df$Country=="Zimbabwe","ZW","BW")

livestock_count_2010_df <- livestock_count_2010_df[order(livestock_count_2010_df$Country, livestock_count_2010_df$LUT),]

write.csv(livestock_count_2010_df,file='output/livestock_by_LUT_2010.csv',row.names = F)