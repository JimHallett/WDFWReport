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
totmammal <-data.frame(sqlFetch(channel, "Mammal view"))
close(channel)

## filter and clean the sql dataframe

mammalyear <- totmammal %>%                                  # fetch data from SQL database
  filter(year(Date)==2014)  %>%                              # set year filter
  filter(Station == "PR-P2") %>%
  select(-Owner, -Station, -Unit, -Habitat, -Common.Name, -Sex:-Year)                  # remove unnecessary columns
          
mammalyear$Day <- day(mammalyear$Date)                       # parse day, month, year
mammalyear$Month <- month(mammalyear$Date)
mammalyear$Year <- year(mammalyear$Date)

mammalsubset1 <- mammalyear  %>% 
  group_by(Northing, Easting, Year, Month, Day, Scientific.Name) %>%
  summarise(Captures=n())

mammalsubset <- select(mammalsubset1, Northing, Easting, Year, Month, Day, Scientific.Name, Captures)

mammalsubset$Observer <- "Permittees"
mammalsubset$Type <- "Museum Specimen"
mammalsubset$Confidence <- "Yes"
mammalsubset$Sex <- "Unknown"
mammalsubset$Age <- "Adult and Juvenile"
mammalsubset$CountAcc <- "100%"
mammalsubset$Location <-"Nonmigratory"
mammalsubset$Comments <- ""
mammalsubset$Coord <- "UTM11"
mammalsubset$Datum <- "NAD27"
mammalsubset$CoordUnit <- "Meters"
mammalsubset$Landmark <- ""
mammalsubset$Owner <- "Tribal"

## rename the columns

mammalsubset <- mammalsubset[c("Observer", "Day", "Month", "Year", "Scientific.Name", "Type", "Confidence", "Sex", "Age",
                               "Captures", "CountAcc", "Location", "Comments", "Coord", "Datum", "CoordUnit", "Easting", "Northing", "Landmark", "Owner")]

write.csv(mammalsubset, file = "Idahomammals.csv")




















## rename the columns

names(mammalsubset)<-(c("Station", "Northing", "Easting", "ScientificName", "CommonName", "NumberCaptured"))






# Final output

finalout <- finalout[c("Start", "End", "ScientificName", "CommonName", "NumberCaptured", 
                       "Northing", "Easting", "County", "Disposition")]

# # Send to a Word document
# 
# reportout = docx()
# reportout = addSection( reportout, landscape = TRUE)
# reportout = addFlexTable(reportout, FlexTable(finalout))
# reportout = addSection( reportout )
# writeDoc( reportout, file = "SCPIdaho2014.docx")
# 
# 
# 
# 
# 
# 






