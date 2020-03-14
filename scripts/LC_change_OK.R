# Create confusion matrices for LC change (by country)
# Run after Calc_LC_Areas_by_LandAdminUnit.R

source('scripts/pkg_functions.R')

# we start with BW — using the land cover brick (in conical equal area projection) prepared earlier in QGIS. 

# cut down the time range to 2000-2018

lc_bw_99_18 <- lc_bw_92_18[[8:27]]
lc_zw_99_18 <- lc_zw_92_18[[8:27]]

# rename the layers in the brick
names(lc_bw_99_18) <- c(paste("HKC_BW_LC_",c(1999:2018),sep="")) 
names(lc_zw_99_18) <- c(paste("HKC_ZW_LC_",c(1999:2018),sep="")) 

lc_bw_99_18 <- reclassify(lc_bw_00_18,rcm)
lc_zw_00_18 <- reclassify(lc_zw_00_18,rcm)

bw_lcc <- lcc_calc(lc_bw_92_18,"BW",c(1999:2018))
bw_lcc <- lcc_calc(lc_zw_99_18,"ZW",c(1999:2018))


head(ct_d)
