### Surface Water

source('scripts/LC_1_ReadManipData.R')

# Read Seasonality data
sh20seas_al_ll_sb <- raster('~/Cloud/OneDrive - United Nations/Data/GeoData/Water/SurfaceWater_JRC/seasonality_20E_10S_v1_1.tif')

sh20seas_al_ll_sb <- crop(sh20seas_al_ll_sb,mask_al_ll_sv)
sh20seas_al_ll_sb_m <- mask(sh20seas_al_ll_sb,mask_al_ll_sv)

sh20seas_al_ea_sb <- projectRaster(sh20seas_al_ll_sb,crs='+proj=aea +lat_1=20 +lat_2=-23 +lat_0=0 +lon_0=25 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs',method='ngb')
# Area of each pixel in sh20seas_al_ea_sb is 25.7x28.5m (the resolution) = 732.45 m2
lc18_resmp_al_ea_sr <- projectRaster(lc1618_al_ea_sb[[3]],sh20seas_al_ea_sb,method='ngb')

sh20byLC_al_ns_tb <- crosstab(sh20seas_al_ea_sb,lc18_resmp_al_ea_sr)

sh20byLC_al_ns_tb <- sh20byLC_al_ns_tb*732.45/1e6 # areas in km2

sh20byLC_al_ns_df <- as.data.frame(sh20byLC_al_ns_tb)
colnames(sh20byLC_al_ns_df) <- c("H2Omonths", "lc_class","area")


sh20byLC_al_ns_df <- merge(sh20byLC_al_ns_df,lcc_simp_ns_tb,by.x="lc_class",by.y="class")
sh20byLC_al_ns_df <- sh20byLC_al_ns_df[,c(2,1,4,3)]
sh20byLC_al_ns_df <- sh20byLC_al_ns_df[order(
  sh20byLC_al_ns_df$H2Omonths,
  sh20byLC_al_ns_df$lc_class,
  sh20byLC_al_ns_df$description,
  sh20byLC_al_ns_df$area,decreasing = c(T,F,F)),]
write.csv(sh20byLC_al_ns_df,'output/surfH2O_byLC.csv',row.names = F)


#### Volume ##### read in SRTM topography data

top1825_al_ll_sr <- raster('~/Cloud/United Nations/UNEP-ESD-Wildlife - General/Projects/ACL_SB-012305_1902-2011/Background/Data/GIS/KAZA_repo/Topo/HKC_SRTM_1arc/s18_e025_1arc_v3_bil/s18_e025_1arc_v3.bil')
top1826_al_ll_sr <- raster('~/Cloud/United Nations/UNEP-ESD-Wildlife - General/Projects/ACL_SB-012305_1902-2011/Background/Data/GIS/KAZA_repo/Topo/HKC_SRTM_1arc/s18_e026_1arc_v3_bil/s18_e026_1arc_v3.bil')
top1924_al_ll_sr <- raster('~/Cloud/United Nations/UNEP-ESD-Wildlife - General/Projects/ACL_SB-012305_1902-2011/Background/Data/GIS/KAZA_repo/Topo/HKC_SRTM_1arc/s19_e024_1arc_v3_bil/s19_e024_1arc_v3.bil')
top1925_al_ll_sr <- raster('~/Cloud/United Nations/UNEP-ESD-Wildlife - General/Projects/ACL_SB-012305_1902-2011/Background/Data/GIS/KAZA_repo/Topo/HKC_SRTM_1arc/s19_e025_1arc_v3_bil/s19_e025_1arc_v3.bil')
top1926_al_ll_sr <- raster('~/Cloud/United Nations/UNEP-ESD-Wildlife - General/Projects/ACL_SB-012305_1902-2011/Background/Data/GIS/KAZA_repo/Topo/HKC_SRTM_1arc/s19_e026_1arc_v3_bil/s19_e026_1arc_v3.bil')
top1927_al_ll_sr <- raster('~/Cloud/United Nations/UNEP-ESD-Wildlife - General/Projects/ACL_SB-012305_1902-2011/Background/Data/GIS/KAZA_repo/Topo/HKC_SRTM_1arc/s19_e027_1arc_v3_bil/s19_e027_1arc_v3.bil')

# topo_al_ll_sr <- merge(top1825_al_ll_sr,top1826_al_ll_sr,top1924_al_ll_sr,top1925_al_ll_sr,top1926_al_ll_sr,top1927_al_ll_sr)
# Above gives unsatisfactory elevations because of the river, so created a shapefile with no river, will use that. 

topo_noriver__al_ll_sr <- merge(top1924_al_ll_sr,top1925_al_ll_sr,top1926_al_ll_sr,top1927_al_ll_sr)
plot(topo_al_ll_sr)

HKC_noriver_al_ll_sv <- read_sf('~/Cloud/United Nations/UNEP-ESD-Wildlife - General/Projects/ACL_SB-012305_1902-2011/Background/Data/GIS/KAZA_repo/Water/HKC_NoRiver_bdy.gpkg')

topo_noriver__al_ll_sr <- crop(topo_noriver__al_ll_sr,HKC_noriver_al_ll_sv)
topo_noriver__al_ll_sr <- mask(topo_noriver__al_ll_sr,HKC_noriver_al_ll_sv)
# lc18_al_ll_sb_resmpl <- projectRaster(lc1618_al_ll_sb[[3]],topo_al_ll_sr)
sh20seas_al_ll_sb_respl <- projectRaster(sh20seas_al_ll_sb,topo_noriver__al_ll_sr)
sh20seas_al_ll_sb_respl <- crop(sh20seas_al_ll_sb_respl,HKC_noriver_al_ll_sv)
sh20seas_al_ll_sb_respl <- mask(sh20seas_al_ll_sb_respl,HKC_noriver_al_ll_sv)

elev_al_ns_df <- zonal(x = topo_noriver__al_ll_sr,sh20seas_al_ll_sb_respl,fun='mean')
