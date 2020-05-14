#### LAND COVER COMPARISON 2000-2018
# Create confusion matrices for LC change (by country)

source('scripts/LC_1_ReadManipData.R')

# we start with the land cover brick (in conical equal area projection) prepared earlier in QGIS. 
# cut down the time range to just two years, 2000 and 2018

lc_bw_2K_2K18 <- lc_bw_92_18[[c(9,27)]]
lc_zw_2K_2K18 <- lc_zw_92_18[[c(9,27)]]

# rename the layers in the brick -- not necessary but comforting
names(lc_bw_2K_2K18) <- c(paste("HKC_BW_LC_",c(2000,2018),sep="")) 
names(lc_zw_2K_2K18) <- c(paste("HKC_ZW_LC_",c(2000,2018),sep="")) 

# Crosstab Land cover and Land Use / Tenure ####

lcc_by_lut_bw_2K <- crosstab(x=lc_bw_2K_2K18[[1]],y=lut_ras_bw)
lcc_by_lut_bw_2K18 <- crosstab(x=lc_bw_2K_2K18[[2]],y=lut_ras_bw)
lcc_by_lut_zw_2K <- crosstab(x=lc_zw_2K_2K18[[1]],y=lut_ras_zw,fun='sum')
lcc_by_lut_zw_2K18 <- crosstab(x=lc_zw_2K_2K18[[2]],y=lut_ras_zw,fun='sum')

#Subtract 2000 vlut_al_ea_sves from 2018 vlut_al_ea_sves
lcc_bw <- lcc_by_lut_bw_2K18 - lcc_by_lut_bw_2K
lcc_zw <- lcc_by_lut_zw_2K18 - lcc_by_lut_zw_2K

lcc_bw <- melt(lcc_bw)
lcc_zw <- melt(lcc_zw)

# fix column names for binding
colnames(lcc_bw) <- c("class","OBJECTID","area_km2")
colnames(lcc_zw) <- c("class","OBJECTID","area_km2")
#add country columns
lcc_bw$country <- "BW"
lcc_zw$country <- "ZW"

# bind the two dataframes
lcc_2K_18 <- rbind(lcc_bw,lcc_zw)

#convert to areas
lcc_2K_18$area_km2 <- lcc_2K_18$area_km*289464.32/1e6
#assign LC and LUT codes
lcc_2K_18 <- merge(lcc_2K_18,lcc_simp_ns_tb,by="class")
lcc_2K_18 <- merge(lcc_2K_18,lut,by="OBJECTID")

#clean up
lcc_2K_18 <- lcc_2K_18[,-1]
colnames(lcc_2K_18) <- c("lc_class","change_area_km2","country","lc_desc","lut")
# reorder columns 
lcc_2K_18 <- lcc_2K_18[,c(3,5,1,4,2)]

# Aggregate data frame
lcc_2K_18 <- aggregate(lcc_2K_18$change_area_km2,list(lcc_2K_18$country,lcc_2K_18$lut,lcc_2K_18$lc_class,lcc_2K_18$lc_desc),FUN=sum)
colnames(lcc_2K_18) <- c("country","lut","lc_class","lc_desc","area_change_km2")
#order data frame
lcc_2K_18 <- lcc_2K_18[order(lcc_2K_18$country,lcc_2K_18$lut,lcc_2K_18$lc_class,lcc_2K_18$lc_desc),]

# remove no change
lcc_2K_18 <- lcc_2K_18[lcc_2K_18$area_change_km2!=0,]
# write out result

write.csv(lcc_2K_18,file = 'output/HKC_lcc_2000-2018_by_lut.csv',row.names = F)
