source('scripts/LC_1_ReadManipData.R')


burn01_al_ll_sb <- brick('~/Cloud/OneDrive - United Nations/Data/GeoData/Fire/MODIS_Fire_KAZA_200011-202004/netCDF/MCD64A1.006_500m_aid0001.nc',varname="Burn_Date")
crs(burn01_al_ll_sb) <- '+proj=longlat +datum=WGS84 +no_defs'

burn01_al_ll_sb <- crop(burn01_al_ll_sb,lc1618_al_ll_sb)

burn01Bin_al_ll_sb <- burn01_al_ll_sb/burn01_al_ll_sb
names(burn01Bin_al_ll_sb) <- names(burn01_al_ll_sb)
plot(burn01Bin_al_ll_sb[[207:218]])
