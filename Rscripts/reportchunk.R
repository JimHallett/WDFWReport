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
sm <-sqlFetch(channel, "Mammal view")  %>%     # fetch data from SQL database
  filter(year(Date)==2013)  %>%                     # set year filter
  select(-Owner, -Unit, -Habitat, -Sex:-Year) 
  
names(sm)<-(c("Date", "Station", "Northing", "Easting", "Scientific_Name", "Common_Name"))
  
smsort <- sm  %>%
arrange(Station, Scientific_Name, Date)   %>%      #, Scientific_Name, Date
count(c("Station", "Northing", "Easting", "Scientific_Name", "Common_Name"))

tbl_df(smsort)

newsum <- data.frame(
   aggregate(Date~Station, data=sm, min),
   aggregate(Date~Station, data=sm, max))

newsum <- newsum %>%
  select(-Station.1)
colnames(newsum) <- c("Station", "Start", "End")

finalout <- merge(smsort,newsum,by="Station")

finalprint <- finalout %>%
  select(-Station)






