# Create confusion matrices for LC change (by country)

source('scripts/LC_1_ReadManipData.R')

# we start with the land cover brick (in conical equal area projection) prepared earlier in QGIS. 
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

lcc <- lcc[order(lcc$country,lcc$year,lcc$from_class,lcc$to_class),]
lcc$change <- ifelse(lcc$from_class==lcc$to_class,"No change",paste(lcc$to_desc," expansion",sep=''))

write.csv(lcc,file = 'output/HKC_lcc_2000_2018.csv')
