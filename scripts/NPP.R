
source('scripts/pkg_functions.R')
#source('scripts/Calc_LC_Areas_by_LandAdminUnit.R')

#### EXTRACT monthly npp from https://www.nature.com/articles/sdata2017165
files <- list.files(path='~/Cloud/OneDrive - United Nations/Data/GeoData/PrimaryProduction/NPP_MODIS17A2_M_PSN_Monthly/',pattern = "*.tif")

npp <- stack(paste("~/Cloud/OneDrive - United Nations/Data/GeoData/PrimaryProduction/NPP_MODIS17A2_M_PSN_Monthly/",files[1],sep=''))

files <- files[-1]

for(i in files) {
  npp <- addLayer(npp,stack(paste("~/Cloud/OneDrive - United Nations/Data/GeoData/PrimaryProduction/NPP_MODIS17A2_M_PSN_Monthly/",i,sep='')))
}

#read polygon masks ####
mask_bw <- read_sf('data/HKC_BW.gpkg')
mask_zw <- read_sf('data/HKC_ZW.gpkg')

# crop npp to bw and zw components respectively
npp_zw <- crop(npp,mask_zw)
npp_bw <- crop(npp,mask_bw)

#Generate dates
t <- c()
for(i in 2000:2016){
  for(j in 1:12){
    r <- paste(i, "-",ifelse(j<10, paste("0",j,sep=''),j),"-15",sep='')
    t <- c(t,r)
  } 
}

# Actual dates are from March 2000 to 

# Cross-tab npp with land cover
# not doing as resolution is too coarse. 
# npp_lc_zw <- xtab_land(npp_zw, mask_zw)
# npp_lc_bw <- xtab_land(npp, masc_bw)

#### Extract npp values ####
g_bw <- Xtract(npp,mask_bw,"npp","BW")
g_zw <- Xtract(npp,mask_zw,"npp","ZW")

g_bw$date <- as.Date(t)
g_zw$date <- as.Date(t)

npp <- rbind(n_bw,n_zw)

write.csv(x = netpp,file='output/HKC_npp_2000-2016.csv',row.names = F)
