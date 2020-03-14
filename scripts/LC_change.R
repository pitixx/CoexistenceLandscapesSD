# Create confusion matrices for LC change (by country)
# Run after Calc_LC_Areas_by_LandAdminUnit.R

source('scripts/pkg_functions.R')

# we start with BW — using the land cover brick (in conical equal area projection) prepared earlier in QGIS. 

# cut down the time range to 2000-2018

lc_bw_99_18 <- lc_bw_92_18[[8:27]]

# rename the layers in the brick
names(lc_bw_99_18) <- c(paste("HKC_BW_LC_",c(1999:2018),sep="")) 

#lc_zw_00_18 <- reclassify(lc_zw_00_18,rcm)
lc_bw_99_18 <- reclassify(lc_bw_00_18,rcm)

ct_bw_l <- list()

# Perform the crosstab (gives a list)
for(i in 1:19) {
    ct_bw_l[[i]] <- crosstab(lc_bw_99_18[[i]],lc_bw_99_18[[i+1]],long=T)
}

#change colnames in each dataframe in the list. 
ct_bw_l <- lapply(ct_bw_l,setNames,c("from_class","to_class","area_km2"))

# add the later year in the comparisin as column in each data frame in the list
ct_bw_l <- Map(cbind, ct_bw_l, year=c(2000:2018))

# bind the dataframes in the list into a single data frame
ct_bw_d <- Reduce(rbind,ct_bw_l)

# add country code
ct_bw_d$country <- "BW"

# add the descriptions of land cover classes
ct_bw_d <- merge(ct_bw_d,y=slcc,by.x=c("from_class"),by.y=c("class"))
names(ct_bw_d)[6] <- "from_desc"

ct_bw_d <- merge(ct_bw_d,y=slcc,by.x=c("to_class"),by.y=c("class"))
names(ct_bw_d)[7] <- "to_desc"

# reorder columns
ct_bw_d <- ct_bw_d[,c(5,4,2,1,6,7,3)]

# convert pixels to areas in km2
ct_bw_d$area_km2 <- ct_bw_d$area_km2*89464.32/1e6

#calc proportion of land affected by each change
for(i in unique(ct_bw_d$year)) {
  ct_bw_d$perc_affected <- 100*ct_bw_d$area_km2/sum(ct_bw_d$area_km2[ct_bw_d$year==i])
}

head(ct_bw_d)
