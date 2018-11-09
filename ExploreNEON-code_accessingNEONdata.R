# AUTHOR: Alexander D. Wright
# DATE: 8 Nov 2018
# DESC: Workshiop code example to use and work with NEON data using relevant packages - this example uses the PAR dataset as an example

#TABLE OF CONTENTS  ( TO BE FINISHED LATER)
# NEON WORKSHOP EXAMPLE           Line#
#Install Packages               Line#
#...                            Line#
#API TUTORIAL
#...
# BIRD DATA                       Line#
#...                            Line#

##
#### INSTALL PACKAGES
##

# #Install packages
# #Provided code that downloads all packages at once
# install.packages("raster")
# install.package("neonUtilities")
# install.packages("devtools")
# 
# source("http://bioconductor.org/biocLite.R")
# biocLite("rhdf5")
# library(devtools)
# install_github("NEONScience/NEON-geolocation/geoNEON")

#Library
library(neonUtilities)
library(geoNEON)
library(raster)
library(rhdf5)

#########
## PART - NEON WORKSHOP EXAMPLE
#########

##
#### DOWNLOAD & STACK DATA (only need to do this once per data product)
##

## System constraints on codes
options(stringsAsFactors = F)

# stack data from portal
#Only have to do this step once (the first time you work the data)
stackByTable("C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON/NEON_par.zip")
#If the folder was previously unzipped, remove '.zip' and add an argument 'folder=T'

## OR

# download observational data with zipsByProduct()
#Only have to do this step once (the first time you work the data)
zipsByProduct(dpID = "DP1.10098.001", 
              site = 'WREF', #site = all for all sites
              package = 'expanded', 
              check.size = T, # turn to false when using a continious workflow
              savepath = "C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON")  
# now stack downloaded data
stackByTable("C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON/filesToStack10098/", folder = T)


## WHAT IF REMOTE SENSING DATA??? Airborne Observation Platform (AOP)

#download AOP data (by individual tile - which is 1km x 1km) resolution (depending on data product is < 1m)
byTileAOP(dpID = 'DP3.30015.001', 
          site = 'WREF', 
          year = '2017',
          easting = 580000,
          northing = 5075000,
          savepath = "C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON"
)


##
#### IMPORT DATA 
##

# Read in PAR 
#Data
par30 <- read.delim("C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON/NEON_par/stackedFiles/PARPAR_30min.csv", sep = ",")
#View(par30)
#variables
parvar <- read.delim("C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON/NEON_par/stackedFiles/variables.csv", sep = ",")
#View(parvar)


# Read in veg structure data
#Mapping and Tagging Data
vegmap <- read.delim("C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON/filesToStack10098/stackedFiles/vst_mappingandtagging.csv", sep = ",")
vegind <- read.delim("C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON/filesToStack10098/stackedFiles/vst_apparentindividual.csv", sep = ",")

# Read in AOP data
chm <- raster('C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif')

##
#### MANAGE DATA 
##

#PAR
#Manipulating time and date data 
#Specifying the format of time and date data
par30$startDateTime <- as.POSIXct(par30$startDateTime,
                                  format="%Y-%m-%d T %H:%M:%S Z",
                                  tz = 'GMT' #ALL NEON DATA IS IN THE SAME TIME ZONE, Greenwich Mean Time (GMT=UTC)
)
head(par30)

#VEG
vegind


##
#### PLOT DATA
##

#PAR
plot(PARMean ~ startDateTime, data=par30[which(par30$verticalPosition == 80),],
     type='l'
)

#VEG

#AOP
plot(chm, col=topo.colors(6))


##
#### Using geoneon
##

vegmap <- geoNEON::def.calc.geo.os(vegmap, 'vst_mappingandtagging')

veg <- merge(vegind, vegmap, by = c("individualID", 'namedLocation', 'domainID', 'siteID', 'plotID'))
symbols(veg$adjEasting[which(veg$plotID =='WREF_085')],
        veg$adjNorthing[which(veg$plotID =='WREF_085')],
        circles=veg$stemDiameter[which(veg$plotID =='WREF_085')]/100,
        xlab='Easting', ylab='Northing', inches=F
)


#########
## PART - API Tutorial (neonscience.org/neon-api-usage)
#########

install.packages('httr')
install.packages('jsonlite')
install.packages('downloader')
library(httr)
library(jsonlite)
library(downloader)

req <- GET("http://data.neonscience.org/api/v0/products/DP1.10003.001")
req
req.content <- content(req, as='parsed')

available <- fromJSON(content(req, as='text'))
str(available$data$siteCodes)

bird.urls <- unlist(available$data$siteCodes$availableDataUrls)
bird <- GET(bird.urls[grep('WOOD/2015-07', bird.urls)])
bird.files <- fromJSON(content(bird, as='text'))

bird.count <- read.delim(bird.files$data$files$url[intersect(grep('countdata', bird.files$data$files$name),
                                                             grep('basic', bird.files$data$files$name))],
                         sep=',')


### .....LOOK AT API CODE TO LEARN MORE ABOUT THE USE OF GEONEON WITH BIRD DATA


#Another example dwithin the API...looking at taxoonomoy
loon.req <- GET('http://data.neonscience.org/api/v0/taxonomy/?family=Gaviidae')
loon.list <- fromJSON(content(loon.req, as='text'))

#########
## PART - EXAMINING THE BIRD DATA
#########

##
#### DOWNLOAD & STACK DATA (only need to do this once)
##

## System constraints on codes
options(stringsAsFactors = F)

# download bird (all sites in all years) observational data with zipsByProduct()
#Only have to do this step once (the first time you work the data)
zipsByProduct(dpID = "DP1.10003.001", 
              site = 'all', 
              package = 'basic', 
              check.size = T, # turn to false when using a continious workflow
              savepath = "C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON")  
# now stack downloaded data
stackByTable("C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON/filesToStack10003/", folder = T)


##
#### IMPORT DATA 
##

# Read in PAR 
#Count Data
birdCount <- read.delim("C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON/filesToStack10003/stackedFiles/brd_countdata.csv", sep = ",")
#Plot/Sample data?
birdPoint <- read.delim("C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON/filesToStack10003/stackedFiles/brd_perpoint.csv", sep = ",")


##
#### MANAGE DATA 
##

#PAR
#Manipulating time and date data 
#Specifying the format of time and date data
par30$startDateTime <- as.POSIXct(par30$startDateTime,
                                  format="%Y-%m-%d T %H:%M:%S Z",
                                  tz = 'GMT' #ALL NEON DATA IS IN THE SAME TIME ZONE, Greenwich Mean Time (GMT=UTC)
)
