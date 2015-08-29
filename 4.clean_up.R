# This program ...... 
library(data.table)

# Load data created from Python
d <- read.csv("complete.csv", header=FALSE)

# Rename variables
oldnames = c('V1','V2','V3','V4','V5','V6','V7','V8','V9','V10','V11','V12','V13','V14','V15')
newnames = c('player','debut','position','tests','wins','losses','draws','points','tries','birthplace','country1','country2','country3','country4','team')
setnames(d, old = oldnames, new = newnames)

# Unknown countries are returned as "g". Make these countries blank.
d$country2 <- as.character(d$country2)
d$country2[d$country1 == 'g'] <- ""

d$country3 <- as.character(d$country3)
d$country3[d$country1 == 'g'] <- ""

d$country1 <- as.character(d$country1)
d$country1[d$country1 == 'g'] <- ""

# Create a new variable that combines all country info.
d$han <- paste(d$country1,d$country2,sep="")
d$han <- paste(d$han,d$country3,sep="")
d$han <- paste(d$han,d$country4,sep="")

#-------------------------------------------------------------#
# Manual Adjustments.
#-------------------------------------------------------------#

# Using country manual adjustment file, assign country.
dic <- read.csv("manual_adjustments/country_codes.csv",header=F)
d1 <- as.character(dic$V1)
COUNTRY <- as.character(dic$V2)
names(COUNTRY) <- d1

# Search for each of the country names within the big geography string, then assign
d$born <- d$country1
for (i in 1:length(COUNTRY)){
odie <- grepl(names(COUNTRY[i]),d$han)
d$born[odie==TRUE]=COUNTRY[[i]]
}

# The remaining errors are now a result of incorrect geocoding in Python.
# The remainder of this code manually corrects some entries, first based on known cities, then players.

# Using city manual adjustment file, assign country.
dic <- read.csv("manual_adjustments/city_codes.csv",header=F)
d1 <- as.character(dic$V1)
CITY <- as.character(dic$V2)
names(CITY) <- d1

# Search for each of the city names within the big geography string, then assign
for (i in 1:length(CITY)){
odie <- grepl(names(CITY[i]),d$birthplace)
d$born[odie==TRUE]=CITY[[i]]
}

# Using player manual adjustment file, assign country.
d$player <- as.character(d$player)
d$birthplace <- as.character(d$birthplace)

dic <- read.csv("manual_adjustments/player_codes1.csv",header=F)
d1 <- as.character(dic$V1)
PLAYER <- as.character(dic$V2)
d3 <- as.character(dic$V3)
names(PLAYER) <- d1

# Search for each of the player names within the name string, then assign
for (i in 1:length(PLAYER)){
odie <- grepl(names(PLAYER[i]),d$player)
d$born[odie==TRUE]=PLAYER[[i]]
d$birthplace[odie==TRUE]=PLAYER_CITY[i]
}

#-------------------------------------------------------------#
# Save
#-------------------------------------------------------------#

new_data <- data.frame("player" = d$player, "team" = d$team, "debut" = d$debut,
                       "tests"=d$tests,"win"=d$wins,"loss"=d$losses, "points"=d$points,"tries"=d$tries,
                       "birthplace" = d$birthplace, "country"=d$born) 
write.csv(new_data, "final_data.csv", row.names=TRUE)



