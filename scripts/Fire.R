source('scripts/LC_1_ReadManipData.R')

burn0118_al_ll_sb <- brick('~/Cloud/OneDrive - United Nations/Data/GeoData/Fire/MODIS_Fire_KAZA_200011-202004/netCDF/MCD64A1.006_500m_aid0001.nc',varname="Burn_Date")
crs(burn0118_al_ll_sb) <- '+proj=longlat +datum=WGS84 +no_defs'

burn0118_al_ll_sb <- crop(burn0118_al_ll_sb,lc1618_al_ll_sb)

burn0118Bin_al_ll_sb <- burn0118_al_ll_sb/burn0118_al_ll_sb
names(burn0118Bin_al_ll_sb) <- names(burn0118_al_ll_sb)
burn0118Bin_al_ll_sb <- burn0118Bin_al_ll_sb[[-c(1:2)]]

burn0118Bin_al_ea_sb_resam <- projectRaster(burn0118Bin_al_ll_sb,lc0018_al_ea_sb,methid='ngb')

### Perform Zonal

n <- data.frame()
g <- 1
h <- 1
for(i in names(lc0018_al_ea_sb)[-1]) {
  for(j in names(burn0118Bin_al_ea_sb_resam)[h:(h+11)]){
    k <- zonal(burn0118Bin_al_ea_sb_resam[[j]],lc0018_al_ea_sb[[i]],fun="sum")
    l <- as.data.frame(cbind.data.frame(k,i,j))
    n <- rbind.data.frame(n,l)
    h <- h+1
  #  browser()
  }
  g <- h
}
burn0118_al_ns_df <- merge(n,lcc_simp_ns_tb,by.x="zone",by.y="class")
burn0118_al_ns_df <- burn0118_al_ns_df[,c(3,4,1,5,2)]
burn0118_al_ns_df$sum <- (burn0118_al_ns_df$sum*res(burn0118Bin_al_ea_sb_resam)[1]*res(burn0118Bin_al_ea_sb_resam)[2])/1e6

names(burn0118_al_ns_df) <- c("year","month","lc_class","lc_descr","burned_area_km2")
burn0118_al_ns_df <- burn0118_al_ns_df[order(burn0118_al_ns_df$month,burn0118_al_ns_df$lc_class),]

burn0118_al_ns_df$year <- substr(burn0118_al_ns_df$year,start = 2,stop = nchar(burn0118_al_ns_df))
burn0118_al_ns_df$month <- substr(burn0118_al_ns_df$month,start = 2,stop = nchar(burn0118_al_ns_df))
burn0118_al_ns_df$month <- gsub(pattern = "\\.","-",burn0118_al_ns_df$month)
burn0118_al_ns_df$month <- as.Date(burn0118_al_ns_df$month)

burn0118_al_ns_df <- burn0118_al_ns_df[,-1]
write.csv(burn0118_al_ns_df,'output/burned_area_2001-2018.csv',row.names = F)

#### ====== THE END.
