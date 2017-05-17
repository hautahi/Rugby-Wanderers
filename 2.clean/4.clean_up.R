# This program "cleans" the resulting dataset from the Python files.
library(readr)
library(dplyr)

# Load data created from Python
d <- read_csv("../1.webscrape/scraped_data.csv")

#-------------------------------------------------------------#
# Remove known errors
#-------------------------------------------------------------#

# Unknown countries returned as "g". Make these countries blank.
d <- d %>% mutate(Bcountry1=replace(Bcountry1, Bcountry=='g', ""),
                      Bcountry2=replace(Bcountry2, Bcountry=='g', ""),
                      Bcountry3=replace(Bcountry3, Bcountry=='g', ""))
d$Bcountry[d$Bcountry == 'g'] <- ""

# Clear known errors in birthcity
d$City[d$City == 'date unknown'] <- ""
d$City[d$City == '?'] <- ""
d$City <- gsub("Co+\\.", "County ", d$City)
d$City <- gsub("\\?", "", d$City)
d$City <- gsub("date unknown+\\,", "", d$City)
d$City <- gsub("\\.", " ", d$City)
d$City <- gsub("\\,+ Northern Ireland", "", d$City)
d$City <- gsub("Co ", "County ", d$City)

# Remove entries if birthcity contains a number
d$Bcountry[grepl(pattern="[[:digit:]]", x=d$City)==TRUE] <- ""
d$Bcountry1[grepl(pattern="[[:digit:]]", x=d$City)==TRUE] <- ""
d$Bcountry2[grepl(pattern="[[:digit:]]", x=d$City)==TRUE] <- ""
d$Bcountry3[grepl(pattern="[[:digit:]]", x=d$City)==TRUE] <- ""
d$City[grepl(pattern="[[:digit:]]", x=d$City)==TRUE]=""

#-------------------------------------------------------------#
# Streamline country names
#-------------------------------------------------------------#

# Load country manual adjustment file and create dictionary
dic <- read_csv("manual_adjustments/country_codes.csv",col_names =F)
COUNTRY <- dic$X2
names(COUNTRY) <- dic$X1

# Create a new variable that combines all country info
d$countrylong <- paste(d$Bcountry,d$Bcountry1,d$Bcountry2,d$Bcountry3,sep=" ")

# Search for each of the country names within the big geography string, then assign
d$born <- d$Bcountry
for (i in 1:length(COUNTRY)){
d$born[grepl(names(COUNTRY[i]),d$countrylong)==TRUE]=COUNTRY[[i]]
}

# Same thing for foreign characters (do here because I can't encode in csv)
d$born[d$born=="日本"] = "Japan"
d$born[d$born=="대한민국"] = "Korea"
d$born[d$born=="中華民國"]="Taiwan"
d$born[d$born=="България"]="Bulgaria"
d$born[d$born=="Österreich"]="Austria"

#-------------------------------------------------------------#
# Manually assign countries according to city name
#-------------------------------------------------------------#

# Load city manual adjustment file
dic <- read_csv("manual_adjustments/city_codes.csv")

# Search for each of the city names within the birthplace variable, then assign country accordingly
for (i in 1:length(dic$City)){
temp <- grepl(dic$City[i],d$City)
d$born[temp==TRUE]=dic$Country[i]
}

d$born[is.na(d$City)]=""

#-------------------------------------------------------------#
# Manually assign details according to player name
#-------------------------------------------------------------#

# Load player manual adjustment file
dic <- read_csv("manual_adjustments/player_codes.csv")

for (i in 1:length(dic$Name)){
  d$born[d$Name==dic$Name[i]]=dic$Country[i]
  d$City[d$Name==dic$Name[i]]=dic$City[i]
}

#-------------------------------------------------------------#
# Manually assign details from NZ Herald Data
#-------------------------------------------------------------#

NZ_Herald <- read_csv("manual_adjustments/NZ_data.csv") %>% select(Number,Name,Place)
NZ_Manual <- read_csv("manual_adjustments/NZ_data_manual.csv")

NZ_index<-left_join(NZ_Manual, NZ_Herald, by = "Number") %>%
  select(Name=Name.x,Place,Number,Debut) %>% mutate(Team="NewZealand",
                                          country=sub('.*,\\s*', '',Place),
                                          cities=gsub("^(.*?),.*", "\\1",Place))

# I join using Team and Debut in order to not double up. For example,
# 2 James Ryan's played for NZ and one for Ireland
d <- left_join(d, NZ_index, by = c("Name" = "Name", "Team" = "Team","Debut"="Debut"))
d$born[!is.na(d$Number)] <- d$country[!is.na(d$Number)]
d$City[!is.na(d$Number)] <- d$cities[!is.na(d$Number)]

# Ensure country names are consistent
for (i in 1:length(COUNTRY)){
  d$born[grepl(names(COUNTRY[i]),d$born)==TRUE]=COUNTRY[[i]]
}

#-------------------------------------------------------------#
# Tidy up Dataset
#-------------------------------------------------------------#

main <- d %>% select(Name,Team,Debut,Position,Matches,Wins,Losses,Draws,Points,Tries,
                         Birthplace=City,Birthcountry=born)

#-------------------------------------------------------------#
# Save
#-------------------------------------------------------------#

# Main Dataset
write_csv(main,"../data/1.main_data.csv")

# Team Specific Datasets
countrylist = c("England", "Scotland", "Ireland", "Wales", "SouthAfrica","Australia",
                "NewZealand", "France", "Argentina", "Italy","Samoa","Tonga","Fiji",
                "Japan","Canada","USA")

for (i in 1:length(countrylist)) {
  path1<-paste("../data/",countrylist[i],".csv",sep = "")
  main %>% filter(Team==countrylist[i]) %>%
    write_csv(path1)
}
