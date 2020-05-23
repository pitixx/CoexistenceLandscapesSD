source('scripts/LC_1_ReadManipData.R')

# Units are in MgC/Ha — or 1/10 Kg/m2
# Source of data https://www.nature.com/articles/s41597-020-0444-4
# Data downloaded from https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1763

carbonA_gl_ll_sr <- raster('~/Cloud/OneDrive - United Nations/Data/GeoData/BiomassCarbon/Above_below_Carbon_2010/C_Above_ground_sdat_1763_3_20200520_022447150.nc')
Above_Carbon <- Carbon_Process(carbonA_gl_ll_sr*10)
Above_Carbon$Layer <- "Above ground"


carbonB_gl_ll_sr <- raster('~/Cloud/OneDrive - United Nations/Data/GeoData/BiomassCarbon/Above_below_Carbon_2010/C_Below_ground_sdat_1763_1_20200520_022347322.nc')
Below_Carbon <- Carbon_Process(carbonB_gl_ll_sr*10)
Below_Carbon$Layer <- "Below ground"

Carbon_AB_2010 <- rbind.data.frame(Above_Carbon,Below_Carbon)

write.csv(Carbon_AB_2010,'output/HKC_CarbonBiomass_2010.csv',row.names = F)

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