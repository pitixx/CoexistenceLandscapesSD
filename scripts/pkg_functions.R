library(raster)
library(sf)
library(ncdf4)
library(lubridate)
library(stars)

# Function right()
right  <-  function(text, num_char) {
  substr(text, nchar(text) - (num_char-1), nchar(text))
}

####  Function xtab to give the count of each type of pixel, which multiplied by 89464.32 and divided by 1e6 will give the area in km2. ####  
xtab_land <- function(lc_brick, mask){
  for(i in 1:length(names(lc_brick))) {
    x <- data.frame()
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

### Function to extract zonal from brick and put in df #### 

Xtract <- function(layer,mask,variab,country) {
  crs(layer) <- " +proj=longlat +datum=WGS84 +no_defs"
  output <- mask(layer,mask)
  output <- crop(layer,mask)
  projected <- st_transform(mask,crs = 102022)
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
  ct_d <- merge(ct_d,y=slcc,by.x=c("from_class"),by.y=c("class"))
  names(ct_d)[6] <- "from_desc"

  ct_d <- merge(ct_d,y=slcc,by.x=c("to_class"),by.y=c("class"))
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
