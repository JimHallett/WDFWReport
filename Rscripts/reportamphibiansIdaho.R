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
  select(Date, Station, Northing, Easting, Scientific.Name, Common.Name, Count) # remove unnecessary columns

amphibyear$Count[is.na(amphibyear$Count)] <- 1               # replace missing values oc Count with 1
             
amphibsubset <- amphibyear  %>% 
  group_by(Date, Station, Northing, Easting, Scientific.Name, Common.Name) %>%
  summarise(Captures=sum(Count))

## rename the columns

names(amphibsubset)<-(c("Station", "Northing", "Easting", "ScientificName", "CommonName", "NumberCaptured"))

## get the date range

daterange <- data.frame(
  aggregate(Date~Station, data=amphibyear, min),
  aggregate(Date~Station, data=amphibyear, max))
daterange <- daterange %>%
  select(-Station.1)
colnames(daterange) <- c("Station", "Start", "End")

## merge capture data and locations with date range

finalout <- merge(amphibsubset,daterange,by="Station") %>%
  select(-Station)  

# Add county and disposition

finalout["County"] <- "Pend Oreille"
finalout["Disposition"] <- "3"

# Final output

finalout <- finalout[c("Start", "End", "ScientificName", "CommonName", "NumberCaptured", 
                       "Northing", "Easting", "County", "Disposition")]

# Send to a Word document

reportout = docx()
reportout = addSection( reportout, landscape = TRUE)
reportout = addFlexTable(reportout, FlexTable(finalout))
reportout = addSection( reportout )
writeDoc( reportout, file = "test.docx")












