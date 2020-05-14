# Create confusion matrices for LC change (by country)

source('scripts/LC_1_ReadManipData.R')

# we start with the land cover brick (in albers equal area projection) prepared earlier in QGIS. 
# cut down the time range to 1999-2018

lc_bw_99_18 <- lc_bw_92_18[[8:27]]
lc_zw_99_18 <- lc_zw_92_18[[8:27]]

# rename the layers in the brick -- not necessary but comforting
names(lc_bw_99_18) <- c(paste("HKC_BW_LC_",c(1999:2018),sep="")) 
names(lc_zw_99_18) <- c(paste("HKC_ZW_LC_",c(1999:2018),sep="")) 

# Calculate LC change transitions ####

bw_lcc <- lcc_calc(lc_bw_99_18,"BW",c(1999:2018))
zw_lcc <- lcc_calc(lc_zw_99_18,"ZW",c(1999:2018))
lcc <- rbind(bw_lcc,zw_lcc)

lcc$from_desc <- as.character.factor(lcc$from_desc)
lcc$to_desc <- as.character.factor(lcc$to_desc)

#sort the table
lcc <- lcc[order(lcc$country,lcc$year,lcc$from_class,lcc$to_class),]

# remove no change transitions
lcc$change <- ifelse(lcc$from_class==lcc$to_class,"No change",paste(lcc$to_desc," expansion",sep=''))

# write out result
write.csv(lcc,file = 'output/HKC_lcc_2000_2018_annual.csv',row.names = F)

##### Land cover change from 2000 to 2018 (single comparison) #### 
lcc_bw_00_18 <- crosstab(lc_bw_99_18[[2]],lc_bw_99_18[[20]],long=T)
lcc_zw_00_18 <- crosstab(lc_zw_99_18[[2]],lc_zw_99_18[[20]],long=T)

# remove no change transitions
lcc_bw_00_18 <- lcc_bw_00_18[lcc_bw_00_18$HKC_BW_LC_2000!=lcc_bw_00_18$HKC_BW_LC_2018,]
lcc_zw_00_18 <- lcc_zw_00_18[lcc_zw_00_18$HKC_ZW_LC_2000!=lcc_zw_00_18$HKC_ZW_LC_2018,]

lcc_bw_00_18$country <- "BW"
lcc_zw_00_18$country <- "ZW"

#change colnames in each dataframe in the list. 
names(lcc_bw_00_18) <- c("from_class","to_class","area_km2","country")
names(lcc_zw_00_18) <- c("from_class","to_class","area_km2","country")
lcc_00_18 <- rbind(lcc_bw_00_18,lcc_zw_00_18)

# convert pixels to areas in km2
lcc_00_18$area_km2 <- lcc_00_18$area_km2*89464.32/1e6

lcc_00_18 <- merge(lcc_00_18,y=lcc_simp_ns_tb,by.x=c("from_class"),by.y=c("class"))
names(lcc_00_18)[5] <- "from_desc"

lcc_00_18 <- merge(lcc_00_18,y=lcc_simp_ns_tb,by.x=c("to_class"),by.y=c("class"))
names(lcc_00_18)[6] <- "to_desc"

# reorder columns
lcc_00_18 <- lcc_00_18[,c(4,2,1,5,6,3)]

# reorder rows
lcc_00_18 <- lcc_00_18[order(lcc_00_18$country,lcc_00_18$from_class,lcc_00_18$to_class),]

# export result
write.csv(lcc_00_18,file = 'output/HKC_lcc_2000_2018.csv',row.names = F)
