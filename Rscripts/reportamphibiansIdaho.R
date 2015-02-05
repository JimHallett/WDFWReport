#####################################################################################################
## WDFW reporting script for scientific collection permit
#####################################################################################################

## required libraries
library(plyr)
library(tidyr)
library(dplyr)
library("RODBC")
library("lubridate")
library( ReporteRs )

## pulldata from SQL view

channel <- odbcConnect("discountasp", uid = "SQL2008_508574_uwmep_user", pwd = "Manis9") 
totamphib <-data.frame(sqlFetch(channel, "Amphibian view"))
close(channel)

## filter and clean the sql dataframe

amphibyear <- totamphib %>%   # fetch data from SQL database
  filter(Taxon == "Amphibian") %>%
  filter(year(Date)==2014)  %>%                              # set year filter
  filter(Station == "PR-P2" | Station == "BM-P2" | Station == "BM-P1") %>%
  select(Date, Station, Northing, Easting, Scientific.Name, Count) # remove unnecessary columns

amphibyear$Count[is.na(amphibyear$Count)] <- 1               # replace missing values oc Count with 1

amphibyear$Day <- day(amphibyear$Date)                       # parse day, month, year
amphibyear$Month <- month(amphibyear$Date)
amphibyear$Year <- year(amphibyear$Date)
             
amphibsubset1 <- amphibyear  %>% 
  group_by(Station, Northing, Easting, Year, Month, Day, Scientific.Name) %>%
  summarise(Captures=sum(Count)) 
  
amphibsubset <- select(amphibsubset1, Northing, Easting, Year, Month, Day, Scientific.Name, Captures)

amphibsubset$Observer <- "Permittees"
amphibsubset$Type <- "Examined in hand or at close range"
amphibsubset$Confidence <- "Yes"
amphibsubset$Sex <- "Unknown"
amphibsubset$Age <- "Larva"
amphibsubset$CountAcc <- "100%"
amphibsubset$Location <-"Juvenile foraging area"
amphibsubset$Comments <- ""
amphibsubset$Coord <- "UTM11"
amphibsubset$Datum <- "NAD27"
amphibsubset$CoordUnit <- "Meters"
amphibsubset$Landmark <- ""
amphibsubset$Owner <- "Tribal"

## rename the columns

amphibsubset <- amphibsubset[c("Station", "Observer", "Day", "Month", "Year", "Scientific.Name", "Type", "Confidence", "Sex", "Age",
  "Captures", "CountAcc", "Location", "Comments", "Coord", "Datum", "CoordUnit", "Easting", "Northing", "Landmark", "Owner")]

write.csv(amphibsubset, file = "IdahoAmphibians.csv")


# # Send to a Word document
# 
# reportout = docx()
# reportout = addSection( reportout, landscape = TRUE)
# reportout = addFlexTable(reportout, FlexTable(finalout))
# reportout = addSection( reportout )
# writeDoc( reportout, file = "test.docx")












