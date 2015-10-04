# This program "cleans" the resulting dataset from the Python files.
library(data.table)
library(plyr)

# Load data created from Python
d <- read.csv("../1.webscrape/complete.csv", header=FALSE)

# Rename variables
oldnames = c('V1','V2','V3','V4','V5','V6','V7','V8','V9','V10','V11','V12','V13','V14','V15','V16','V17')
newnames = c('player','debut','position','tests','wins','losses','draws','tries','points','birthplace','country1','country2','country3','country4','month','birthyear','team')
setnames(d, old = oldnames, new = newnames)

#-------------------------------------------------------------#
# Remove known errors
#-------------------------------------------------------------#

# Unknown countries returned as "g". Make these countries blank.
d$country2 <- as.character(d$country2)
d$country3 <- as.character(d$country3)
d$country4 <- as.character(d$country4)
d$country1 <- as.character(d$country1)

d$country2[d$country1 == 'g'] <- ""
d$country3[d$country1 == 'g'] <- ""
d$country4[d$country1 == 'g'] <- ""
d$country1[d$country1 == 'g'] <- ""

# Clear known errors in birthplace
d$birthplace[d$birthplace == 'date unknown'] <- ""
d$birthplace[d$birthplace == '?'] <- ""

d$country1[grepl(pattern="[[:digit:]]", x=d$birthplace)==TRUE] <- ""
d$country2[grepl(pattern="[[:digit:]]", x=d$birthplace)==TRUE] <- ""
d$country3[grepl(pattern="[[:digit:]]", x=d$birthplace)==TRUE] <- ""
d$birthplace[grepl(pattern="[[:digit:]]", x=d$birthplace)==TRUE]=""

d$born[grepl(pattern="[[:digit:]]", x=d$birthplace)==TRUE]=""

#-------------------------------------------------------------#
# Streamline country names
#-------------------------------------------------------------#

# Load country manual adjustment file and create dictionary
dic <- read.csv("manual_adjustments/country_codes.csv",header=F)
COUNTRY <- as.character(dic$V2)
names(COUNTRY) <- as.character(dic$V1)

# Create a new variable that combines all country info
d$han <- paste(d$country1,d$country2,d$country3,d$country4,sep=" ")

# Search for each of the country names within the big geography string, then assign
d$born <- d$country1
for (i in 1:length(COUNTRY)){
d$born[grepl(names(COUNTRY[i]),d$han)==TRUE]=COUNTRY[[i]]
}

# Same thing for Japan (do here because I can't encode Japanese characters in csv)
d$born[d$born=="日本"] = "JAP"
d$born[d$born=="대한민국"] = "KOR"

# The remaining errors are now a result of incorrect geocoding in Python.

#-------------------------------------------------------------#
# Manually assign countries according to city name
#-------------------------------------------------------------#

# Load city manual adjustment file and create dictionary
dic <- read.csv("manual_adjustments/city_codes.csv",header=F)
CITY <- as.character(dic$V2)
names(CITY) <- as.character(dic$V1)

# Search for each of the city names within the birthplace variable, then assign country accordingly
for (i in 1:length(CITY)){
odie <- grepl(names(CITY[i]),d$birthplace)
d$born[odie==TRUE]=CITY[[i]]
}

#-------------------------------------------------------------#
# Manually assign details according to player name
#-------------------------------------------------------------#

# Load player manual adjustment file and name variables
dic <- read.csv("manual_adjustments/player_codes.csv",header=F)
d1 <- as.character(dic$V1)
PLAYER <- as.character(dic$V2)
PLAYER_CITY <- as.character(dic$V3)
names(PLAYER) <- d1

d$player <- as.character(d$player)
d$birthplace <- as.character(d$birthplace)

# Search for each of the player names (exact match) within the name string, then assign country and maybe city
for (i in 1:length(PLAYER)){
  d$born[d$player==names(PLAYER[i])]=PLAYER[[i]]
  d$birthplace[d$player==names(PLAYER[i])]=PLAYER_CITY[i]
}

#-------------------------------------------------------------#
# Manually assign details from NZ Herald Data
#-------------------------------------------------------------#
# The NZ Herald compiled a comprehensive list. This section exploits
# that list

NZ_Herald <- read.csv("manual_adjustments/NZ_data.csv",header=T)
NZ_Manual <- read.csv("manual_adjustments/NZ_data_manual.csv",header=F)

NZ_Manual$Number <- NZ_Manual$V2

plyr1 <- join(NZ_Manual, NZ_Herald, by = "Number")
keepvars <- c("V1","Place","Number")
NZ_index <- plyr1[keepvars]

names(NZ_index)[names(NZ_index)=="V1"] <- "player"
NZ_index$country <- sub('.*,\\s*', '', NZ_index$Place)
NZ_index$cities <- gsub("^(.*?),.*", "\\1", NZ_index$Place)

d <- join(d, NZ_index, by = "player")
d$born[!is.na(d$Number)] <- d$country[!is.na(d$Number)]
d$birthplace[!is.na(d$Number)] <- d$cities[!is.na(d$Number)]

for (i in 1:length(COUNTRY)){
  d$born[grepl(names(COUNTRY[i]),d$born)==TRUE]=COUNTRY[[i]]
}

#-------------------------------------------------------------#
# Save
#-------------------------------------------------------------#

new_data <- data.frame("player" = d$player, "team" = d$team, "debut" = d$debut,
                       "tests"=d$tests,"win"=d$wins,"loss"=d$losses, "draw"=d$draws,"points"=d$points,
                       "tries"=d$tries, "birthplace" = d$birthplace, "country"=d$born,"month"=d$month,"birthyear"=d$birthyear) 
write.csv(new_data, "../final_data.csv", row.names=FALSE)
