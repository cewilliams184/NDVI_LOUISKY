# NDVI_LOUISKY
convert NAIP imagery data to NDVI raster data in R

Groups NAIP imagery in a listy by year. Each list is then ran through a loop that calculates the NDVI value. 
The loop stacks the raster files which allows processing on multi-banded raster files. The stacks are then bricked which saves all the bands in the same place,
speeding up processing. Each raster is converted into a raster object before the NDVI calculation is performed. 

Finally the NDVI rasters are reprojected into the local coordinate system and merged by year.
