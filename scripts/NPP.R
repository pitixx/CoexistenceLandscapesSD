
source('scripts/LC_1_ReadManipData.R')
library(reshape)

#### extract monthly npp ###
# data downloaded from https://neo.sci.gsfc.nasa.gov/archive/geotiff.float/MOD17A2_M_PSN/
# For details see https://neo.sci.gsfc.nasa.gov/view.php?datasetId=MOD17A2_M_PSN

#### extract monthly npp ###

files <- list.files(path='~/Cloud/OneDrive - United Nations/Data/GeoData/PrimaryProduction/NPP_MODIS17A2_M_PSN_Monthly/',pattern = "*.tif")

npp <- stack(paste("~/Cloud/OneDrive - United Nations/Data/GeoData/PrimaryProduction/NPP_MODIS17A2_M_PSN_Monthly/",files[1],sep=''))

files <- files[-1]

for(i in files) {
  npp <- addLayer(npp,stack(paste("~/Cloud/OneDrive - United Nations/Data/GeoData/PrimaryProduction/NPP_MODIS17A2_M_PSN_Monthly/",i,sep='')))
}

#read polygon masks ####
mask_bw_ll_sv <- read_sf('data/HKC_BW.gpkg')
mask_zw_ll_sv <- read_sf('data/HKC_ZW.gpkg')

# crop npp to bw and zw components respectively
npp_zw <- crop(npp,mask_zw_ll_sv)
npp_bw <- crop(npp,mask_bw_ll_sv)

npp_bw <- mask(npp_bw,mask_bw_ll_sv)
npp_zw <- mask(npp_zw,mask_zw_ll_sv)

# mask the land use & tenure rasters for each country

lut_al_ea_sv_bw <- lut_al_ea_sv[lut_al_ea_sv$Country=='Botswana',9]
lut_al_ea_sv_zw <- lut_al_ea_sv[lut_al_ea_sv$Country=='Zimbabwe',9]

lut_ras_bw <- crop(lut_ras_bw,lut_al_ea_sv_bw)
lut_ras_zw <- crop(lut_ras_zw,lut_al_ea_sv_zw)

lut_ras_bw <- mask(lut_ras_bw,lut_al_ea_sv_bw)
lut_ras_zw <- mask(lut_ras_zw,lut_al_ea_sv_zw)

# ### Project rasters to Albers Equal Area ####
npp_bw_ea <- projectRaster(npp_bw,lut_ras_bw,method="ngb")
npp_zw_ea <- projectRaster(npp_zw,lut_ras_zw,method="ngb")


# #Project lut_al_ea_sv to WGS84
 lut_al_ea_sv_g <- st_transform(lut_al_ea_sv,crs=4326)

### Extract npp vlut_al_ea_sves by lanc use / tenure ####

# lut_al_ea_sv_bw <- lut_al_ea_sv_g[lut_al_ea_sv_g$Country=="Botswana",9]
# lut_al_ea_sv_zw <- lut_al_ea_sv_g[lut_al_ea_sv_g$Country=="Zimbabwe",9]

npp_lut_bw <- zonal(x=npp_bw_ea,z=lut_ras_bw,fun='mean',progress='text')
npp_lut_zw <- zonal(x=npp_zw_ea,z=lut_ras_zw,fun='mean',progress='text')

npp_lut_bw_df <- as.data.frame(t(npp_lut_bw))
npp_lut_zw_df <- as.data.frame(t(npp_lut_zw))

colnames(npp_lut_bw_df) <- npp_lut_bw_df[1,]
colnames(npp_lut_zw_df) <- npp_lut_zw_df[1,]

npp_lut_bw_df <- npp_lut_bw_df[-1,]
npp_lut_zw_df <- npp_lut_zw_df[-1,]

# Botswana has an extra, empty column that belongs to zim (v4, 22 - Wildlife State), so we remove it
npp_lut_bw_df <- npp_lut_bw_df[,-4]

##### LUT RAS rasterized lut_al_ea_sv based on object ID, so now we check what they relate to and apply them to the new data frames
names(npp_lut_bw_df) <- lut_al_ea_sv_g$LUT[lut_al_ea_sv_g$Country=="Botswana"]
names(npp_lut_zw_df) <- lut_al_ea_sv_g$LUT[lut_al_ea_sv_g$Country=="Zimbabwe"]

#Generate dates
dates <- c()
for(i in 2000:2016){
  for(j in 1:12){
    r <- paste(i, "-",ifelse(j<10, paste("0",j,sep=''),j),"-15",sep='')
    dates <- c(dates,r)
  } 
}

# Actual dates are from Feb 2000 to November 2016, so adjust t accordingly
dates <- dates[-c(1,204)]

npp_lut_bw_df$date <- as.Date(dates)
npp_lut_zw_df$date <- as.Date(dates)

### melt the DFs 
npp_lut_bw_df <- melt(npp_lut_bw_df,id=c("date"))
npp_lut_zw_df <- melt(npp_lut_zw_df,id=c("date"))

npp_lut_bw_df$country <- "BW"
npp_lut_zw_df$country <- "ZW"

#### Create new df that binds the two countries and clean up ####
npp <- rbind(npp_lut_bw_df,npp_lut_zw_df)

npp <- npp[,c(4,1,2,3)]

# Summarize the data frame, with one LUT entry per country and year
npp2 <- aggregate(npp$vlut_al_ea_sve,list(npp$country,npp$date,npp$variable),FUN=sum)

names(npp2) <- c("country","date","land use (tenure)","npp")

#### Add areas from aggregated lut_al_ea_sv_g ####
lut_al_ea_sv_g_agg <- aggregate(lut_al_ea_sv_g$AreaKm2,by=list(lut_al_ea_sv_g$Country,lut_al_ea_sv_g$LUT),FUN=sum)

names(lut_al_ea_sv_g_agg) <- c("country","land use (tenure)","area_km2")
# lut_al_ea_sv_g_agg$`land use (tenure)` <- lut_al_ea_sv_g_agg$`land use (tenure)`
# lut_al_ea_sv_g_agg$country <- lut_al_ea_sv_g_agg$country

lut_al_ea_sv_g_agg$country <- ifelse(lut_al_ea_sv_g_agg$country=="Botswana","BW","ZW")

npp4 <- merge(lut_al_ea_sv_g_agg,npp2,by=c("country","land use (tenure)"))
npp4 <- npp4[,c(1,4,2,3,5)]

#sort the df
npp4 <- npp4[order(npp4$country,npp4$date,npp4$`land use (tenure)`),]

write.csv(x = npp4,file='output/HKC_npp_2000-2016.csv',row.names = F)
