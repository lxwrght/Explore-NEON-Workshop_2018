# AUTHOR: Alexander D. Wright
# DATE: 10 Nov 2018
# DESC: Code to access, download, and reformat data from NEON (specifically bird, small mammals, and beetle data)


#TABLE OF CONTENTS  ( TO BE FINISHED LATER)
  # ?????
    #Install Packages               Line#
      #...                            Line#
    #Download and Reformat Data
      #...
# BIRD DATA                       Line#
#...                            Line#

#########
## PART - ?????
#########

##
#### SET WORKING DIRECTORY 
##

dir <- getwd()
dirPaste <- paste(dir,'/AWE_Day2_Exercise', sep = "")



##
#### INSTALL PACKAGES
##

# Necessary packages
library(neonUtilities)
library(geoNEON)
library(raster)
library(rhdf5)

# Download data from portal via R
options(stringsAsFactors = F)
# download observational data with zipsByProduct()
#Only have to do this step once (the first time you work the data)
  #Birds
dirPaste <- paste(dir,'/Data/Birds', sep = "")
zipsByProduct(dpID = "DP1.10003.001",   #DPI for Bird Point Count data
              site = 'all',
              package = 'basic',
              check.size = T, # turn to false when using a continious workflow
              savepath = dirPaste)
# now stack downloaded data
dirPaste <- paste(dir,'/Data/Birds/filesToStack10003', sep = "")
stackByTable(dirPaste, folder = T)
  #Mammals
  #Beetles




