#####################################################################################################
## WDFW reporting script for scientific collection permit
#####################################################################################################

## required libraries
library(tidyr)
library(dplyr)
library("RODBC")
library("lubridate")

## pulldata from SQL view

channel <- odbcConnect("discountasp", uid = "SQL2008_508574_uwmep_user", pwd = "Manis9") 
totmammal <-data.frame(sqlFetch(channel, "Mammal view"))
close(channel)

## filter and clean the sql dataframe

mammalsubset <- totmammal %>%                                  # fetch data from SQL database
  filter(year(Date)==2014)  %>%                                # set year filter
  select(-Owner, -Unit, -Habitat, -Sex:-Year)                  # remove unnecessary columns

mammalyear <- mammalsubset %>%          
  arrange(Station, Northing, Easting, Scientific.Name, Common.Name)  %>%            # sort the data
  count(c("Station", "Northing", "Easting", "Scientific.Name", "Common.Name"))      # count by station and species

## rename the columns

names(mammalyear)<-(c("Station", "Northing", "Easting", "ScientificName", "CommonName", "NumberCaptured"))

## get the date range

daterange <- data.frame(
  aggregate(Date~Station, data=mammalsubset, min),
  aggregate(Date~Station, data=mammalsubset, max))
daterange <- daterange %>%
  select(-Station.1)
colnames(daterange) <- c("Station", "Start", "End")

## merge capture data and locations with date range

finalout <- merge(mammalyear,daterange,by="Station") %>%
  select(-Station)  

# Add county and disposition

finalout["County"] <- "Pend Oreille"
finalout["Disposition"] <- "3"

# Final output

finalout <- finalout[c("Start", "End", "ScientificName", "CommonName", "NumberCaptured", 
                       "Northing", "Easting", "County", "Disposition")]














