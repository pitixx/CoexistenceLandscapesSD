source('scripts/pkg_functions.R')

#### Read Data ####

# 1992-2015 land cover for the BW and ZW componwents of HKC (prepared earlier in Qgis)
#lc stands for land cover

lc_zw_92_15 <- brick('data/HKC_ZW_LC_1992-2015.tif')
lc_bw_92_15 <- brick('data/HKC_BW_LC_1992-2015.tif')


#Now we rasterize the polygon layer
  # First create an empty raster of the same dimensions
lut_ras_zw <- raster(lc_zw_92_15[[1]])
lut_ras_bw <- raster(lc_bw_92_15[[1]])

#Rasterize
lut_ras_zw <- rasterize(alu_ea,y = lut_ras_zw,field="OBJECTID")
lut_ras_bw <- rasterize(alu_ea,y = lut_ras_bw,field="OBJECTID")

# Now we add 2016-18
#Read the land cover rasters 
# Reading from NetCDF4

lc16_18 <- stack('~/Cloud/OneDrive - United Nations/Data/GeoData/LandCover/ESA/C3S-LC-L4-LCCS-Map-300m-P1Y-2016-v2.1.1.nc',
              '~/Cloud/OneDrive - United Nations/Data/GeoData/LandCover/ESA/C3S-LC-L4-LCCS-Map-300m-P1Y-2017-v2.1.1.nc',
              '~/Cloud/OneDrive - United Nations/Data/GeoData/LandCover/ESA/C3S-LC-L4-LCCS-Map-300m-P1Y-2018-v2.1.1.nc')

lc16_18zw <- crop(lc16_18,mask_zw)
lc16_18bw <- crop(lc16_18,mask_bw)

#clip extent zw & bw
lc16_18bw <- mask(lc16_18bw,mask_bw)
lc16_18bw <- crop(lc16_18bw,mask_bw)

lc16_18zw <- mask(lc16_18zw,mask_zw)
lc16_18zw <- crop(lc16_18zw,mask_zw)

#project to Albers Conical Equal Area
lc16_18bw <- projectRaster(lc16_18bw,lut_ras_bw,method="ngb")
lc16_18zw <- projectRaster(lc16_18zw,lut_ras_zw,method="ngb")

## Add the three latest layers to the main brick
lc_zw_92_18 <- addLayer(lc_zw_92_15,lc16_18zw)
lc_bw_92_18 <- addLayer(lc_bw_92_15,lc16_18bw)

## Reclass Bricks to simplify Land Cover

lc_zw_92_18 <- reclassify(lc_zw_92_18,rcm)
lc_bw_92_18 <- reclassify(lc_bw_92_18,rcm)

#TO DO: correct classification of Pandamatenga farms 


##### Generate CrossTabs #####
dat <- data.frame()

dat <- xtab_land(lc_zw_92_18,lut_ras_zw)
len_zw <- length(dat$au_code)
dat <- xtab_land(lc_bw_92_18,lut_ras_bw)
len_dat <- length(dat$au_code)

# now calculate the proper areas
dat$area <- dat$area*89464.32/1e6

# # Check areas, they should add up to the WDA area
 for(x in unique(dat$year)){
  print(sum(dat$area[dat$year==x]))
 }
# 

#add the country names
dat$country <- NA
dat$country[1:len_zw] <- "ZW"
# dat$country[len_zw+1:len_dat] <- "BW"
dat$country <- ifelse(is.na(dat$country),"BW",dat$country)

#clean out the empties
length(dat$area[dat$area==0])

dat <- dat[dat$area!=0,]

# replace the class codes by land use / tenure classes

# y <- data.frame(cbind(alu_ea$OBJECTID,alu_ea$Land.Use,alu_ea$Tenure,alu_ea$LU_detail))
# names(y) <- c("OBJECTID","land_use_tenure")

dat$au_code <- as.numeric(dat$au_code)

dat$land_use_tenure <- 
        ifelse(dat$au_code==1, "Commercial Agriculture (Private)",
               ifelse(dat$au_code>=2 & dat$au_code<6,"Forest (State)",
                      ifelse(dat$au_code>5 & dat$au_code<9,"Mixed (Communal)",
                             ifelse(dat$au_code>8 & dat$au_code<20,"Mixed (Private)",
                                    ifelse(dat$au_code==20,"Wildlife (Communal)",
                                           ifelse(dat$au_code==21,"Wildlife (Private)","Wildlife (State)"))))))

dat$lu_detail <- ifelse(dat$au_code==1, "Commercial Agriculture",
                        ifelse(dat$au_code>1 & dat$au_code<6,"Forestry",
                               ifelse(dat$au_code>5 & dat$au_code<13,"Arable/pastoral/built",
                                      ifelse(dat$au_code>12 & dat$au_code<15,"Pastoral/bush/built",
                                             ifelse(dat$au_code==15,"Arable/pastoral/built/mining",
                                                    ifelse(dat$au_code==17,"Pastoral/bush/built",
                                                           ifelse(dat$au_code==18,"Mining/pastoral/bush/built", 
                                                              ifelse(dat$au_code==19, "Arable/pastoral/built","Wildlife"
                                                                     ))))))))
names(dat)
dat <- dat[,-2]

# data <- merge(dat,lccs)
data <- merge(dat,slcc)

names(data) <- c("lc_class","area_km2","year","country","land_use_tenure","lu_detail","description")
# reorder columns
data <- data[,c(3,4,5,6,1,7,2)]
data <- data[order(data$year,data$country,data$land_use_tenure,data$class),]

test <- tapply(data$area_km2,INDEX =list(data$year,data$country,data$land_use_tenure,data$description),FUN=sum)
# write output
write.csv(data,file = 'output/hkc_luc_1992-2018.csv')

