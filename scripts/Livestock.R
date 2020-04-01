source('scripts/LC_1_ReadManipData.R')

livestock_al_ll_sb <- brick('~/Cloud/OneDrive - United Nations/Data/GeoData/Livestock/FAO/AF_Cattle1km_AD_2010_GLW2_01_TIF/AF_Cattle1km_AD_2010_v2_1.tif')

livestock_al_ll_sb <- addLayer(livestock_al_ll_sb,'~/Cloud/OneDrive - United Nations/Data/GeoData/Livestock/FAO/AF_Goats1km_AD_2010_v2_1_TIF/AF_Goats1km_AD_2010_v2_1.tif')

livestock_al_ll_sb <- addLayer(livestock_al_ll_sb,'~/Cloud/OneDrive - United Nations/Data/GeoData/Livestock/FAO/AF_Sheep1km_AD_2010_GLW2_1_TIF/AF_Sheep1km_AD_2010_v2_1.tif')

livestock_al_ll_sb <- addLayer(livestock_al_ll_sb,'~/Cloud/OneDrive - United Nations/Data/GeoData/Livestock/FAO/AF_TLU_Ruminants/AF_TLU_ruminants.tif')

liv_tv <- c("cattle","goats","sheep","tlu")

# Crop and mask
livestock_al_ll_sb <- crop(livestock_al_ll_sb,alu)

livestock_al_ll_sb <- mask(livestock_al_ll_sb,alu)

# Rasterize alu_ea
alu_al_ea_sr <

alu_al_ll_sr <- rasterize(x=alu,y=livestock_al_ll_sb,field="OBJECTID")
alu_al_ea_sr <- projectRaster(alu_al_ll_sr,crs='+proj=aea +lat_1=20 +lat_2=-23 +lat_0=0 +lon_0=25 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs',method='ngb')

# Project livestock to equal area 
livestock_al_ea_sb <- projectRaster(livestock_al_ll_sb,crs='+proj=aea +lat_1=20 +lat_2=-23 +lat_0=0 +lon_0=25 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs')

livestock_count_2010_df <- as.data.frame(zonal(livestock_al_ea_sb,alu_al_ea_sr,fun='sum'))
names(livestock_count_2010_df) <- c("OBJECTID","Cattle","Goats","Sheep","Small_Rumin_TLU")

livestock_count_2010_df <- merge(livestock_count_2010_df,lut_al_df,by='OBJECTID')

livestock_count_2010_df <- livestock_count_2010_df[,c(6,7,8,2,3,4,5)]

livestock_count_2010_df <- aggregate(livestock_count_2010_df[,c(3:7)],by=list(livestock_count_2010_df$Country,livestock_count_2010_df$LUT),FUN=sum)

names(livestock_count_2010_df) <- c("Country", "LUT","area_km2","cattle","goats","sheep","small_rumin_TLU")
livestock_count_2010_df$Country <-  ifelse(livestock_count_2010_df$Country=="Zimbabwe","ZW","BW")

livestock_count_2010_df <- livestock_count_2010_df[order(livestock_count_2010_df$Country, livestock_count_2010_df$LUT),]

write.csv(livestock_count_2010_df,file='output/livestock_by_LUT_2010.csv',row.names = F)
