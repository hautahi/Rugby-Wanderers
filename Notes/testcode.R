## @knitr main
# This program "tests" code used in writeup

library(readr)
library(dplyr)
library(ascii)
cutoff <- 1995

# Load player data
df <- read_csv("../data/1.main_data.csv")
d <- read_csv("../data/1.main_data.csv") %>% filter(Debut>cutoff)

# ###########################
# Imports Stuff
# ###########################

d1 <- d %>% group_by(Team) %>%
  summarise(TotalPlayers =n(), TotalPoints=sum(Points), TotalTries=sum(Tries))
d2 <- d %>% group_by(Team,Birthcountry) %>%
  summarise(Players =n(),Points=sum(Points),Tries=sum(Tries),Matches=sum(Matches))
Missing <- d2 %>% filter(is.na(Birthcountry)) %>% select(-Birthcountry)

d3 <- d %>% group_by(Team,Birthcountry) %>%
  summarise(NativePlayers =n(),points=sum(Points)) %>%
  filter(Team==Birthcountry) %>%  left_join(d1,.,by="Team") %>%
  left_join(Missing,by="Team") %>%
  mutate(Missing=ifelse(is.na(Players),0,Players),
         `Foreign Born`=TotalPlayers-NativePlayers-Missing,
         `Foreign Born (%)`=`Foreign Born`/(NativePlayers+`Foreign Born`)*100) %>%
  select(Team,`Total`=TotalPlayers,
         `Native Born`=NativePlayers,
         `Foreign Born`,
         `Foreign Born (%)`,
         `Missing Birth Information`=Missing) %>% arrange(desc(`Foreign Born (%)`))

# ###########################
# Migration Stuff
# ###########################

# m <- read_csv("../data/DP_LIVE_22032.csv") %>% select(Country = LOCATION,TIME,Value) %>%
#   filter(TIME>2010) %>% group_by(Country) %>%
#   summarise("Foreign born Population (%)"=mean(Value)) %>%
#   filter(Country=="AUS" | Country=="CAN" | Country=="FRA" | Country=="England"
#          | Country=="IRL" | Country=="ITA" | Country=="JPN" | Country=="NZL" | 
#            Country=="USA" | Country=="Wales" | Country == "Scotland"| Country == "GBR")
# 
# temp <- data_frame(Country=c("England","Wales","Scotland"),
#                    "Foreign born Population (%)"=c(m$`Foreign born Population (%)`[m$Country=="GBR"],
#                        m$`Foreign born Population (%)`[m$Country=="GBR"],
#                        m$`Foreign born Population (%)`[m$Country=="GBR"])) 
# 
# m$Country[m$Country=="AUS"]="Australia"
# m$Country[m$Country=="CAN"]="Canada"
# m$Country[m$Country=="FRA"]="France"
# m$Country[m$Country=="IRL"]="Ireland"
# m$Country[m$Country=="ITA"]="Italy"
# m$Country[m$Country=="JPN"]="Japan"
# m$Country[m$Country=="NZL"]="NewZealand"
# 
# m1 <- m %>% rbind_list(temp) %>% mutate(Team=Country) %>% left_join(d3,by="Team") %>%
#   select(Team,`Foreign born Population (%)`,
#          `Foreign born Players (%)`=`Foreign Born (%)`) %>%
#   mutate(Ratio=`Foreign born Players (%)`/`Foreign born Population (%)`) %>%
#   filter(Team!="GBR") %>% arrange(desc(`Foreign born Population (%)`))

m <- read_csv("../data/WorldBankData/Data.csv") %>% 
  filter(`Series Name`=="International migrant stock (% of population)") %>%
  select(Country,`Foreign born Population (%)`=`2010`)

m$Country[m$Country=="New Zealand"]="NewZealand"
m$Country[m$Country=="South Africa"]="SouthAfrica"
m$Country[m$Country=="United States"]="USA"

temp <- data_frame(Country=c("England","Wales","Scotland"),
                    "Foreign born Population (%)"=c(m$`Foreign born Population (%)`[m$Country=="United Kingdom"],
                        m$`Foreign born Population (%)`[m$Country=="United Kingdom"],
                        m$`Foreign born Population (%)`[m$Country=="United Kingdom"])) 

m1 <- m %>% rbind_list(temp) %>% mutate(Team=Country) %>% left_join(d3,by="Team") %>%
  select(Team,`Foreign born Population (%)`,
         `Foreign born Players (%)`=`Foreign Born (%)`) %>%
  mutate(Ratio=`Foreign born Players (%)`/`Foreign born Population (%)`) %>%
  filter(Team!="United Kingdom") %>% arrange(`Ratio`)

#############
missingcutoff <- 0.1
temp <- d3 %>% mutate(MissingRate=ifelse(is.na(`Missing Birth Information`/`Total`)
                                         ,0,`Missing Birth Information`/`Total`)) %>%
  filter(MissingRate<=missingcutoff)
COUNTRY <- d1$Team
COUNTRY_S <- c(temp$Team,"Samoa","Fiji")

temp1 <- d2 %>% filter(Team %in% COUNTRY_S) %>%
  mutate(check=ifelse(Birthcountry %in% COUNTRY_S,Birthcountry,"Other"),
         check=ifelse(is.na(Birthcountry),"Missing",check)) %>%
  group_by(Team,check) %>% summarise(Players=sum(Players))

library(tidyr)
d_wide <- spread(temp1, check, Players) %>% mutate(missing1=Missing,other1=Other) %>%
  select(-Missing,-Other) %>% mutate(Other=other1,Missing=missing1) %>%
  select(-missing1,-other1) %>% left_join(d1,by="Team") %>%
  mutate(Total=TotalPlayers) %>% select(-TotalPlayers,-TotalPoints,-TotalTries)

d_wide[is.na(d_wide)] <- 0

#############
# Create points/player table etc
d5 <- d2 %>%
  mutate(Status=ifelse(is.na(Birthcountry),"Missing",
                       ifelse(Team==Birthcountry,"Native","Foreign"))) %>%
  select(-Birthcountry) %>% filter(Status!="Missing",Team %in% COUNTRY) %>%
  group_by(Team,Status) %>% summarise_each(funs(sum)) %>%
  mutate(PpP = Points/Players,TpP=Tries/Players,MpP=Matches/Players)

dpoints <- d5 %>% select(Team,Status,PpP) %>% spread(Status,PpP) %>%
  select(Team,`Points per Native Player`=Native,`Points per Foreign Player`=Foreign)
dtries <- d5 %>% select(Team,Status,TpP) %>% spread(Status,TpP) %>%
  select(Team,`Tries per Native Player`=Native,`Tries per Foreign Player`=Foreign)
dmatches <- d5 %>% select(Team,Status,MpP) %>% spread(Status,MpP) %>%
  select(Team,`Matches per Native Player`=Native,`Matches per Foreign Player`=Foreign)

d6 <- left_join(dmatches,dpoints,by="Team") %>% left_join(dtries,by="Team")

#############

MissingPlayers <- d %>% filter(Team %in% COUNTRY_S,is.na(Birthcountry)) %>%
  select(-Birthplace,-Birthcountry)

#############

posies <- d %>% mutate(Status=ifelse(is.na(Birthcountry),"Missing",
                                   ifelse(Team==Birthcountry,"Native","Foreign")),
                     Position = ifelse(is.na(Position),"Unknown",Position)) %>%
  separate(Position,into = c("Position", "Pos2"),sep=",")

d7 <- posies$Position
d7[d7=="Wing"|d7=="Outside back"|d7=="Fullback"|d7=="Utility back"|
     d7=="Scrum-half"|d7=="Five-eighth"|d7=="Fly-half"|d7=="Halfback"|
     d7=="Centre"] <- "Backs"
d7[d7=="Lock"|d7=="Front-row"|d7=="Prop"|d7=="Hooker"|
     d7=="No. 8"|d7=="Flanker"|d7=="Utility forward"|d7=="Back-row"] <- "Forwards"
d7 <- as.data.frame(d7)  

posies <- cbind(posies, d7) %>% filter(Status!="Missing") %>%
  unite(Status,Status,d7,sep="-") %>%
  select(Team,Status) %>% group_by(Team,Status) %>%
  summarise(count=n()) %>% spread(Status, count) %>%
  mutate(`Native Forward:Back Ratio`=`Native-Forwards`/`Native-Backs`,
         `Foreign Forward:Back Ratio`=`Foreign-Forwards`/`Foreign-Backs`) %>%
  select(Team,`Native Forward:Back Ratio`,`Foreign Forward:Back Ratio`)

#############

Expo <- d %>% filter(Team!=Birthcountry) %>%
  group_by(Birthcountry) %>%
  summarise(Players =n(),points=sum(Points),tries=sum(Tries),matches=sum(Matches)) %>%
  arrange(desc(Players)) %>%
  mutate(ppp=points/Players,tpp=tries/Players,mpp=matches/Players) %>%
  select(Birthcountry,`Exported Players`=Players,`Points per Player`=ppp,`Tries per Player`=tpp,
         `Matches per Player`=mpp) %>% mutate(Team=Birthcountry) 

d9 <- Expo[,1:2] %>% filter(row_number() <= 12)

TotalExports <- d %>% filter(Team!=Birthcountry) %>%
  group_by(Birthcountry) %>% summarise(Players =n()) %>% select(Players) %>%
  summarise(sum(Players))

Trade <- d3 %>% select(Team,`Foreign Born`) %>% left_join(Expo,by="Team") %>%
  select(Team,Imports=`Foreign Born`,Exports=`Exported Players`) %>%
  mutate(`Trade Balance`=Exports-Imports) %>% arrange(desc(`Trade Balance`))

