#####################################################################################################
## WDFW reporting script for scientific collection permit
#####################################################################################################

## required libraries
library(plyr)
library(tidyr)
library(dplyr)
library("RODBC")
library("lubridate")

## pulldata from SQL view

channel <- odbcConnect("discountasp", uid = "SQL2008_508574_uwmep_user", pwd = "Manis9") 
totmammal <-data.frame(sqlFetch(channel, "Mammal view"))
close(channel)

## filter and clean the sql dataframe

mammalyear <- totmammal %>%                                  # fetch data from SQL database
  filter(year(Date)==2014)  %>%                              # set year filter
  filter(Station != "PR-P2")
  select(-Owner, -Unit, -Habitat, -Sex:-Year)                  # remove unnecessary columns
             
mammalsubset <- mammalyear  %>% 
  group_by(Station, Northing, Easting, Scientific.Name, Common.Name) %>%
  summarise(Captures=n())

## rename the columns

names(mammalsubset)<-(c("Station", "Northing", "Easting", "ScientificName", "CommonName", "NumberCaptured"))

## get the date range

daterange <- data.frame(
  aggregate(Date~Station, data=mammalyear, min),
  aggregate(Date~Station, data=mammalyear, max))
daterange <- daterange %>%
  select(-Station.1)
colnames(daterange) <- c("Station", "Start", "End")

## merge capture data and locations with date range

finalout <- merge(mammalsubset,daterange,by="Station") %>%
  select(-Station)  

# Add county and disposition

finalout["County"] <- "Pend Oreille"
finalout["Disposition"] <- "3"

# Final output

finalout <- finalout[c("Start", "End", "ScientificName", "CommonName", "NumberCaptured", 
                       "Northing", "Easting", "County", "Disposition")]

finalout











