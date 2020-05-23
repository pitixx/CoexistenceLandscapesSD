source('scripts/LC_1_ReadManipData.R')
require(rts)

### Functions ####

monthly_avg <- function(x) {
  t <- as.Date(as.character(x@z$time))
  y <- rts(x,t)
  z<- apply.monthly(x = y,FUN=mean)
  return(z)
}

align2LC <- function(data_rb,landcover_rb,mask_sv){
  x<- crop(data_rb,landcover_rb)
  x <- mask(x,mask_sv)
  return(x)
}

resamp_lc <- function(lc_rb,data_rb){
  x <- projectRaster(lc_rb,data_rb,method='ngb')
return(x)
}

# aet0018_mth_hk_ns_df

# aet0018_mth_al_rts
# data_rts <- aet0018_mth_al_rts
# lc_rb <- lc0018_al_ll_sb_resam

temporal_zonal <- function(data_rts,lc_rb){
  n <- data.frame()
  g <- 1
  h <- 1
  for(i in names(lc_rb)) {
    for(j in data_rts@time[h:(h+11)]){
      k <- zonal(data_rts[[j]],lc_rb[[i]],fun="mean")
      l <- as.data.frame(cbind.data.frame(k,year=i,date=as.character(index(data_rts@time[j]))))
      n <- rbind.data.frame(n,l)
      h <- h+1
      #browser()
    }
    g <- h
  }
  return(n)
}


tidyUp_df <- function(et_data_df,var_name){
  x <- merge(et_data_df,lcc_simp_ns_tb,by.x="zone",by.y="class")
  x <- x[,c(4,1,5,2)]
  x <- x[order(x$date,x$zone),]
  names(x) <- c("date","lc_class","lc_descr",var_name)
  return(x)
}

# Read data ####
# Source: https://modis.gsfc.nasa.gov/data/dataprod/mod16.php 
# Data downloaded from https://lpdaac.usgs.gov/products/mod16a2v006/

aet0018_8d_al_ll_sb <- brick('~/Cloud/OneDrive - United Nations/Data/GeoData/EvapoTransp/NASA_MOD16_EvapoTransp/HKC_EvapoTransp/MOD16A2GF.006_500m_aid0001.nc',varname='ET_500m')
crs(aet0018_8d_al_ll_sb)<- '+proj=longlat +datum=WGS84 +no_defs'

pet0018_8d_al_ll_sb <- brick('~/Cloud/OneDrive - United Nations/Data/GeoData/EvapoTransp/NASA_MOD16_EvapoTransp/HKC_EvapoTransp/MOD16A2GF.006_500m_aid0001.nc',varname='PET_500m')
crs(pet0018_8d_al_ll_sb)<- '+proj=longlat +datum=WGS84 +no_defs'

## Crop abd align to LC ####
aet0018_8d_hk_ll_sb <- align2LC(aet0018_8d_al_ll_sb,lc0018_al_ll_sb,lut_al_ll_sv)
pet0018_8d_hk_ll_sb <- align2LC(pet0018_8d_al_ll_sb,lc0018_al_ll_sb,lut_al_ll_sv)

lc0018_al_ll_sb_resam <- resamp_lc(lc0018_al_ll_sb,aet0018_8d_hk_ll_sb)

# Average (a/p)et to monthly values. ####
aet0018_mth_al_rts <- monthly_avg(aet0018_8d_hk_ll_sb)
pet0018_mth_al_rts <- monthly_avg(pet0018_8d_hk_ll_sb)

### Perform Zonal ####

aet0018_mth_hk_ns_df <- temporal_zonal(aet0018_mth_al_rts,lc0018_al_ll_sb_resam)
pet0018_mth_hk_ns_df <- temporal_zonal(pet0018_mth_al_rts,lc0018_al_ll_sb_resam)

# Clean up ####
et_data_df <- tidyUp_df(aet0018_mth_hk_ns_df,"aet_lm2m")
et_data_df$pet_lm2m <- tidyUp_df(pet0018_mth_hk_ns_df,"pet_lm2m")$pet_lm2m

write.csv(et_data_df,'output/HKC_EvapTrans_2000-2018.csv',row.names = F)

#### ====== THE END.
