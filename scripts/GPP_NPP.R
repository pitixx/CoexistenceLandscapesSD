
source('scripts/pkg_functions.R')
#source('scripts/Calc_LC_Areas_by_LandAdminUnit.R')

#### EXTRACT monthly GPP from https://www.nature.com/articles/sdata2017165
files <- list.files(path='~/Cloud/OneDrive - United Nations/Data/GeoData/PrimaryProduction/GPP_Zhangetal2017/monthly_0.5/',pattern = "*.tif")

gpp <- stack(paste("~/Cloud/OneDrive - United Nations/Data/GeoData/PrimaryProduction/GPP_Zhangetal2017/monthly_0.5/",files[1],sep=''))

files <- files[-1]

for(i in files) {
  gpp <- addLayer(gpp,stack(paste("~/Cloud/OneDrive - United Nations/Data/GeoData/PrimaryProduction/GPP_Zhangetal2017/monthly_0.5/",i,sep='')))
}


# crop gpp to bw and zw components respectively
gpp_zw <- crop(gpp,mask_zw_ll_sv)
gpp_bw <- crop(gpp,mask_bw_ll_sv)

t <- c()
for(i in 2000:2016){
  for(j in 1:12){
    r <- paste(i, "-",ifelse(j<10, paste("0",j,sep=''),j),"-15",sep='')
    t <- c(t,r)
  } 
}

# Cross-tab gpp with land cover
# not doing as resolution is too coarse. 
# gpp_lc_zw <- xtab_land(gpp_zw, mask_zw_ll_sv)
# gpp_lc_bw <- xtab_land(gpp, masc_bw)

#### Extract gpp vlut_al_ea_sves ####
g_bw <- Xtract(gpp,mask_bw_ll_sv,"gpp","BW")
g_zw <- Xtract(gpp,mask_zw_ll_sv,"gpp","ZW")

g_bw$date <- as.Date(t)
g_zw$date <- as.Date(t)

gpp <- rbind(n_bw,n_zw)

write.csv(x = netpp,file='output/HKC_GPP_2000-2016.csv',row.names = F)
