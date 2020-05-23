library(raster)
library(sf)
library(ncdf4)
library(lubridate)
library(stars)
library(reshape)

# Function right()
right  <-  function(text, num_char) {
  substr(text, nchar(text) - (num_char-1), nchar(text))
}

####  Function xtab to give the count of each type of pixel, which multiplied by 89464.32 and divided by 1e6 will give the area in km2. ####  
xtab_land <- function(lc_brick, mask){
  for(i in 1:length(names(lc_brick))) {
    x <- data.frame
    x<- as.data.frame(crosstab(lc_brick[[i]],mask))
    x$year <- 1991+i
    names(x) <- c("class","au_code","area","year")
    dat <- rbind(dat,x)
  }
  return(dat)
}

#### Function to declare raster bricks as categorical ####
ratirat <- function(brick){
  for(i in length(names(brick)))
    ratify(brick[[i]])
}

#### Function to Asign latlong to raster with NA CRS
assign_ll <- function(rs_layer_na_crs){
  crs(rs_layer_na_crs) <- " +proj=longlat +datum=WGS84 +no_defs"  
}


### Function to extract zonal from brick and put in df #### 
Xtract <- function(rs_layer,rs_zones,variab,country) {
  output <- mask(rs_layer,rs_zones)
  output <- crop(rs_layer,rs_mask)
  projected <- st_transform(rs_zones,crs = 102022)
  blank <- raster(projected)
  projected_raster <- rasterize(x = projected, y = blank,field="OBJECTID")
  output <- projectRaster(to =projected_raster,from = output,method="ngb")
  x <- zonal(output,projected_raster,fun=mean)
  y <- as.data.frame(t(x))
  names(y) <- c(variab)
  y$country <- country
  y$date <- substr(row.names(y),2,11)
  y$date <- gsub(pattern = "\\.","-",y$date)
  row.names(y) <- c()
  y <- y[-1,]
  y <- y[,c(2,3,1)]
  return(y)
}


#Function to crop global map to study area, resample to match land cover 
resamp_crop_transf <- function(data_ww_ll_sx,mask_al_ll_sv,mask_1c_ll_sv,lcmask_al_ll_rx,method){
  x <- crop(data_ww_ll_sx,mask_al_ll_sv)
  x <- projectRaster(data_ww_ll_sx,lcmask_al_ll_rx,method = method)
  x <- mask(x,mask_al_ll_sv)
  x <- crop(x,mask_1c_ll_sv)
  # rm(data_ww_ll_sx)
  return(x) 
}

### Function to extract zonal by LC classes from brick and put in df ####
#### layers must all be in projection and extent. 

Xtract_byLC <- function(data_raster,zones_raster,country,func) {
  x <- as.data.frame(zonal(data_raster,zones_raster,fun=func))
  measures <-  names(x[-1])
  y <- melt.data.frame(data = x,id.vars = "zone",measure.vars = measures)
  y$country <- country
  return(y)
}


clean_myclim_data <- function(y,var) {
  y$variable <- substr(y$variable,2,11)
  y$variable <- gsub(pattern = "\\.","-",y$variable)
  y <- merge(y,lcc_simp_ns_tb,by.x='zone',by.y='class')
  colnames(y) <- c("lc_class", "date", var,"country","lc_desc")
  y <- y[,c(4,2,1,5,3)]
  return(y)
}

clean_mylstock_data <- function(y){
  y <- merge(y,lcc_simp_ns_tb,by.x='zone',by.y='class')
  y <- y[,c(4,2,1,5,3)]
  names(y) <- c("country","species","lc_zone","lc_desc","heads")
  y <- y[order(y$country,y$species,y$lc_zone,y$lc_desc,y$heads),]
  return(y)
}


clean_myclim_data <- function(y){
  y$variable <- substr(y$variable,2,11)
  y$variable <- gsub(pattern = "\\.","-",y$variable)
  y <- merge(y,lcc_simp_ns_tb,by.x='zone',by.y='class')
  colnames(y) <- c("lc_class", "date", var,"country","lc_desc")
  y <- y[,c(4,2,1,5,3)]
}


##### Function to calculate annual land cover changes ####

lcc_calc <- function(brick,country,year_range) {
  ct_l <- list()
    # Perform the crosstab (gives a list)
  for(i in 1:(length(year_range)-1)) {
    ct_l[[i]] <- crosstab(brick[[i]],brick[[i+1]],long=T)
  }
    #change colnames in each dataframe in the list. 
    ct_l <- lapply(ct_l,setNames,c("from_class","to_class","area_km2"))
  
    # add the later year in the comparison as column in each data frame in the list
    ct_l <- Map(cbind, ct_l, year=c(2000:2018))

    # bind the dataframes in the list into a single data frame
  ct_d <- Reduce(rbind,ct_l)

# add country code
  ct_d$country <- country

# add the descriptions of land cover classes
  ct_d <- merge(ct_d,y=lcc_simp_ns_tb,by.x=c("from_class"),by.y=c("class"))
  names(ct_d)[6] <- "from_desc"

  ct_d <- merge(ct_d,y=lcc_simp_ns_tb,by.x=c("to_class"),by.y=c("class"))
  names(ct_d)[7] <- "to_desc"

# reorder columns
  ct_d <- ct_d[,c(5,4,2,1,6,7,3)]

# convert pixels to areas in km2
  ct_d$area_km2 <- ct_d$area_km2*89464.32/1e6

#calc proportion of land affected by each change
  for(i in unique(ct_d$year)) {
  ct_d$perc_affected <- 100*ct_d$area_km2/sum(ct_d$area_km2[ct_d$year==i])
  }
  return(ct_d)
}

### Function to process Carbon data #### 
## Testing only : carbon_map <- carbonA_gl_ll_sr

Carbon_Process <- function(carbon_map) {
  carbon_al_ll_sr <- crop(carbon_map,lc0018_al_ll_sb)
  
  carbon_al_ll_sr_resmp <- projectRaster(carbon_al_ll_sr,lc0018_al_ll_sb)
  
  carbon_al_ll_sr_resmp <- mask(carbon_al_ll_sr_resmp,lut_al_ll_sv)
  
  carbon_al_ns_df <- as.data.frame(zonal(carbon_al_ll_sr_resmp,lc0018_al_ll_sb[[11]],fun='mean'))
  
  carbon_al_ns_df <- merge(carbon_al_ns_df,lcc_simp_ns_tb,by.x="zone",by.y="class")
  
  names(carbon_al_ns_df) <- c("lc_class","dens_MgC_Ha","lc_desc")
  carbon_al_ns_df <- carbon_al_ns_df[,c(1,3,2)]
  
  ### scale correction as per paper
  ## Paper reports tenths of MgC/Ha, so we multiply by 10
  carbon_al_ns_df$dens_MgC_Ha <- carbon_al_ns_df$dens_MgC_Ha#*10
  return(carbon_al_ns_df)
}

