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

# y <- data.frame(cbind(lut_al_ea_sv$OBJECTID,lut_al_ea_sv$Land.Use,lut_al_ea_sv$Tenure,lut_al_ea_sv$LU_detail))
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

# data <- merge(dat,lccs_ns_tb)
data <- merge(dat,lcc_simp_ns_tb)

names(data) <- c("lc_class","area_km2","year","country","land_use_tenure","lu_detail","description")
# reorder columns
data <- data[,c(3,4,5,6,1,7,2)]
data <- data[order(data$country,data$year,data$land_use_tenure,data$lc_class),]

test <- tapply(data$area_km2,INDEX =list(data$year,data$country,data$land_use_tenure,data$description),FUN=sum)
# write output
write.csv(data,file = 'output/hkc_luc_1992-2018.csv',row.names = F)

