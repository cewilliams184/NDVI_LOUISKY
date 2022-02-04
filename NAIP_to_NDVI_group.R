#load spatial packages
library(raster)
library(rgdal)
library(rgeos)
library(RColorBrewer)
library(hash)

#set working directory
setwd("D:/TreeCover_LOUKY/RawData/NAIP")
pathz <- "D:/TreeCover_LOUKY/RawData/NAIP"

#import naip data in a single folder as a list
rastlist <- list.files(path = "D:/TreeCover_LOUKY/RawData/NAIP", pattern='.tif', all.files=TRUE, full.names=FALSE)

#list rasters by year
#2020
#rastlist2020 <- list.files(path=pathz, pattern = "(2020).*\\.tif$") #create list rasters collected in 2020
#length2020 <- length(rastlist2020) #find number of elements in rastlist2020
#2018
#rastlist2018 <- list.files
#length2018 <- length (rastlist2018) #find number of elements in rastlist2020
#2016
#rastlist2016 <- list.files(path="C:/TreeCover_LOUKY/RawData/LIDAR/BulkDownload/NAIP", pattern = "(2016).*\\.tif$")
#length2016 <- length (rastlist2016) #find number of elements in rastlist2016
#2014
#rastlist2014 <- list.files(path="C:/TreeCover_LOUKY/RawData/LIDAR/BulkDownload/NAIP", pattern = "(2014).*\\.tif$")
#length2014 <- length (rastlist2014) #find number of elements in rastlist2014
#2012
#rastlist2012 <- list.files(path="C:/TreeCover_LOUKY/RawData/LIDAR/BulkDownload/NAIP", pattern = "(2012).*\\.tif$")
#length2012 <- length (rastlist2012) #find number of elements in rastlist2012
#2010
rastlist2010 <- list.files(path=pathz, pattern = "(2010).*\\.tif$")
length2010 <- length(rastlist2010) #find number of elements in rastlist2010

Allrastlist <- list(rastlist2010)

count = 1
year = 2010

for (d in Allrastlist){

  #import naip data as a stack for each raster in 2020 list
  for (x in d)
  {
    divide <-strsplit(d[[1]][[1]], "_")
    year <- substring(divide[[1]][[6]], 0,4)
    split <-strsplit(x,"_") #split the raster file name by _
    orientation <-split[[1]][3] #pull the orientation of the raster from the raster file name
    outname = gsub("\\s","", paste(year, "_", orientation, "_st",count)) #create out put name and remove whitespaces with gsub
    a <- stack(x) #import each naip .tif as a stack to read all bands of the .tif 
    writeRaster(a, filename=outname, overwrite=FALSE) #save to variable with unique name
    count = count + 1
  }
  
  #list of 2020 stacked files
  stlist <- list.files(path=pathz, pattern = sprintf("%s.*\\.gri$", year))
  
  #convert stack to a raster brick. A rasterbrick in R, saves all of the bands in the same place making it faster when you process the data.
  countB = 1 #used to call element in outname_br list created in loop
  for (xs in stlist)
  {
   outname_br <-gsub('st', 'br', xs) #removes 'st' from filename and replaces it with br
   outname_br_grd <-gsub('gri','grd', outname_br)
   b <- brick(xs) #create brick for each elementwr
   writeRaster(b, filename=outname_br_grd, overwrite=TRUE)
  }
  countB = countB + 1 # specify correct element in outname_br list
  
  #list of  stacked files
  brlist <- gsub('st', 'br', stlist) #just replaces st with br
  
  #create raster objects from each year list
  NAIP <- lapply(brlist, raster) #import one years rasters as raster objects
  NAIP <- NAIP[20:40]
  
  #function to calculate NDVI Vegetation index (NIR - Red)/ (NIRb + Red) using the red (band 1) and nir (band 4) bands
  #calculate NDVI for each tile in NAIPYEAR list
  # setwd("D:/TreeCover_LOUKY/RawData/NAIP")
  
  countNDVI = 1
  for ( y in NAIP)
  {
    split <-strsplit(names(y),"_") #split the raster file name by _
    orientation <-split[[1]][3] #pull the orientation of the raster from the raster file name
    year <- substring(split[[1]][[6]], 0,4)
    outname_naip = gsub("\\s","", paste(year,"_", orientation, "_ndvi", countNDVI))#create out put name and remove whitespaces with gsub
    naipNDVI_y<- (raster(brlist[[(countNDVI)]], band=4) - raster(brlist[[(countNDVI)]], band=1)) / (raster(brlist[[(countNDVI)]], band= 4) + raster(brlist[[(countNDVI)]], band=4)) #2020
    writeRaster(naipNDVI_y, filename = outname_naip, overwrite=TRUE)
    countNDVI = countNDVI + 1
  }
  
  
  #list of 2020 NDVI  files
  ndviListYr <- list.files(path=pathz, pattern = sprintf("(%s|ndvi).*\\.gri$", year))
}

#List 2010 NDVI files
#year = 2010
NDVIR <-NULL
NDVIRList <-NULL
NDVIList<-NULL
NDVIList <- list.files(path=pathz, pattern=sprintf("(ndvi).*\\.gri$"))
#NDVI <-ndviListYr[1:4]
for (x in NDVIList){
  NDVIRList <- append(NDVIRList, raster(x))
}
NDVIR <-NDVIRList[41:81]

#merge rasters by year - 2010 
#mNDVI <-do.call(merge, NDVIR)
#plot(mNDVI)
#writeRaster(mNDVI, filename = 'NDVI2010_merged', overwrite=TRUE)

#import parcel data
setwd("C:/Student/GIS590/ClientFiles/Data/Preprocessing/")

#import parcel data
JeffCoParcels<-readOGR(dsn=paste0(getwd()),layer="Jefferson_County_KY_Parcels", verbose=FALSE)

setwd("D:/TreeCover_LOUKY/RawData/NAIP")

#merge rasters in groups - groups of 6 or less (so raster to point conversion can run and not get overwhelmed with processing size)
GP1 <- list(NDVIRList[1:6])
GP2 <- list(NDVIRList[7:12])
GP3 <- list(NDVIRList[13:18])
GP4 <- list(NDVIRList[19:24])
GP5 <- list(NDVIRList[25:30])
GP6 <- list(NDVIRList[31:36])
GP7 <- list(NDVIRList[37:40])

Grouplist <-list(GP1, GP2, GP3, GP4, GP5, GP6, GP7)

mcount = 1
for (x in Grouplist){
  GP <-do.call(merge, GP1)
  NDVI2010_projGP <-projectRaster(GP, crs=crs(JeffCoParcels))
  writeRaster(NDVI2010_projGP[(mcount)], filname='NDVI2010Gp(%s)',mcount, overwrite=TRUE)
  mcount = mcount +1
}

#crop and mask NDVI2010
NDVI2010_crop <-crop(NDVI2010_proj, limit_proj)
NDVI2010_cram <-mask(NDVI2010_crop, limit_proj)
NDVI2010_mask <-NDVI2010_cram
#plot(NDVI2010_mask)
writeRaster(NDVI2010_mask, filename = 'NDVI2010_masked', overwrite=TRUE)

#write raster to file if extract correctly otherwise will do in arcmap





















