## @knitr main
# This program "tests" code used in writeup

library(readr)
library(dplyr)
library(ascii)
cutoff <- 1995

target <-  c("Argentina","Australia","England","France","Ireland","New Zealand",
             "Scotland","South Africa","Wales","Italy")

# Load player data
d <- read_csv("../data/1.main_data.csv") %>%
  as.data.frame() %>% filter(Debut>cutoff) %>%
  mutate(Team = ifelse(Team=="SouthAfrica","South Africa",Team),
         Birthcountry = ifelse(Birthcountry=="SouthAfrica","South Africa",Birthcountry),
         Team = ifelse(Team=="NewZealand","New Zealand",Team),
         Birthcountry = ifelse(Birthcountry=="NewZealand","New Zealand",Birthcountry))

han <- read_csv("../data/1.main_data.csv") %>% as.data.frame() %>%
  mutate(Team = ifelse(Team=="SouthAfrica","South Africa",Team),
         Birthcountry = ifelse(Birthcountry=="SouthAfrica","South Africa",Birthcountry),
         Team = ifelse(Team=="NewZealand","New Zealand",Team),
         Birthcountry = ifelse(Birthcountry=="NewZealand","New Zealand",Birthcountry)) %>%
  select(-Position,-Wins,-Losses,-Draws) %>% filter(Debut>1900) %>% arrange(-Debut) %>%
  filter(Team %in% target)

# ###########################
# Crunch Data
# ###########################

# Create Totals For each Team
d1 <- d %>% group_by(Team) %>%
  summarise(TotalPlayers = n(), TotalPoints = sum(Points), TotalTries = sum(Tries),
            TotalMatches = sum(Matches))

# Create totals by Team and Birth Country
d2 <- d %>% group_by(Team,Birthcountry) %>%
  summarise(Players =n(),Points=sum(Points),Tries=sum(Tries),
            Matches=sum(Matches)) %>%
  mutate(Birthcountry = ifelse(is.na(Birthcountry),"Missing",Birthcountry))

# Create stats for missing players (This allows us to calculate foreign stats below)
Missing <- d2 %>% filter(Birthcountry=="Missing") %>% select(-Birthcountry) %>%
  rename(MissPlayers = Players, MissPoints=Points,MissTries=Tries,MissMatches=Matches)

# Create Full Data Frame
fin_df <- left_join(d1,d2,by="Team") %>% left_join(Missing,by="Team") %>%
  mutate(MissPlayers=ifelse(is.na(MissPlayers),0,MissPlayers),
         MissPoints=ifelse(is.na(MissPoints),0,MissPoints),
         MissTries=ifelse(is.na(MissTries),0,MissTries),
         MissMatches=ifelse(is.na(MissMatches),0,MissMatches))

# Create Full Data Frame 2
fin_df2 <- fin_df %>% filter(Team==Birthcountry) %>%
  rename(NativePlayers = Players, NativePoints=Points, NativeTries=Tries,
         NativeMatches=Matches) %>% select(-Birthcountry) %>%
  mutate(`ForeignPlayers`=TotalPlayers-NativePlayers-MissPlayers,
         `ForeignPoints`=TotalPoints-NativePoints-MissPoints,
         `ForeignTries`=TotalTries-NativeTries-MissTries,
         `ForeignMatches`=TotalMatches-NativeMatches-MissMatches,
         `Foreign Born (%)`=ForeignPlayers/(NativePlayers+ForeignPlayers)*100)

# ###########################
# Total Debut Graph
# ###########################

library(reshape2)
Debut_d <- fin_df2 %>% select(Team,"Native Players" = NativePlayers,"Foreign Players"=ForeignPlayers,
                  "Total Players" =TotalPlayers) %>%
  melt(,id.vars = "Team", measure.vars = c("Native Players", "Foreign Players")) %>%
  filter(Team %in% target)

library(ggplot2)
Debut_g <- ggplot(Debut_d, aes(x=Team, y=value, fill=variable)) +
  geom_bar(stat='identity') +  scale_fill_brewer(palette='Pastel1') +
  labs(y="Number of players",x="") + theme_bw() +
  theme(legend.title=element_blank(),
        axis.ticks.x=element_blank(),
        legend.position="bottom",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank()) + coord_cartesian(ylim = c(0, 300))

# ###########################
# Foreign Born Player Percentage
# ###########################

library(tidyr)
test <- fin_df2 %>% filter(Team %in% target) %>%
  select(Team,"Native" = NativePlayers,"Foreign"=ForeignPlayers,
         "Total" =TotalPlayers) %>%
  mutate(Team=ifelse(Team=="New Zealand","New&nbsp;Zealand",Team),
         Team=ifelse(Team=="South Africa","South&nbsp;Africa",Team)) %>%
  t() %>% as.data.frame()
colnames(test) <- as.character(unlist(test[1,]))
test <- test[-1,] 

group.colors <- c(Argentina = "#75AADB", Australia = "#FCD116", England ="#fbf1e3",
                  France="Blue", Ireland = "#00843D",`New Zealand`="Black",
                  Scotland="#006CB4", `South Africa`="#007C59", Wales="#D21034",
                  Italy="#007FFF")

FB <- fin_df2 %>% filter(Team %in% target) %>% arrange(-`Foreign Born (%)`)

FB_g <- FB %>%
  ggplot(aes(x=reorder(Team, -`Foreign Born (%)`),
                            y=`Foreign Born (%)`,fill=Team,label = `Foreign Born (%)`)) +
  geom_bar(stat = "identity") + theme_bw() +
  scale_fill_manual(values=group.colors) + 
  theme(axis.ticks.x=element_blank(),
    legend.title=element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank()) + ylim(c(0,50)) +
  labs(y="Foreign Born Percentage",x="") + theme(legend.position="none")

# ###########################
# Foreign Born Player vs Population
# ###########################

m <- read_csv("../data/WorldBankData/Data.csv") %>% as.data.frame() %>%
  filter(`Series Name`=="International migrant stock (% of population)") %>%
  select(Country,`Foreign born Population (%)`=`2010`)

m$Country[m$Country=="United States"]="USA"

temp <- data_frame(Country=c("England","Wales","Scotland"),
                   "Foreign born Population (%)"=c(m$`Foreign born Population (%)`[m$Country=="United Kingdom"],
                                                   m$`Foreign born Population (%)`[m$Country=="United Kingdom"],
                                                   m$`Foreign born Population (%)`[m$Country=="United Kingdom"])) 

m1 <- m %>% bind_rows(temp) %>% mutate(Team=Country) %>% 
  filter(Team!="United Kingdom") %>% select(-Country) %>%
  left_join(fin_df2,by="Team") %>%
  rename(`Foreign Born Players (%)`=`Foreign Born (%)`) %>%
  melt(id.vars = "Team", 
       measure.vars = c("Foreign Born Players (%)", "Foreign born Population (%)")) %>%
  filter(Team %in% target)
  
popcompare_g <- ggplot(m1, aes(x=Team, y=value, fill=variable)) +
  geom_bar(stat='identity',position='dodge') +  scale_fill_brewer(palette='Pastel1') +
  labs(y="Foreign Born (%)",x="") + theme_bw() + coord_cartesian(ylim = c(0, 50)) +
  theme(legend.title=element_blank(),
        legend.position="bottom",
        axis.ticks.x=element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank()) 

# ###########################
# Player Exporters
# ###########################

Expo <- d %>% filter(Team!=Birthcountry) %>%
  group_by(Birthcountry) %>%
  summarise(Players =n(),points=sum(Points),tries=sum(Tries),matches=sum(Matches)) %>%
  arrange(desc(Players),Birthcountry)

Expo1 <- Expo %>% top_n(10)

Expo_g <- Expo %>% top_n(10) %>%
  ggplot(aes(x=reorder(Birthcountry, -Players),
             y=Players)) +
  geom_bar(stat = "identity",fill='#b3cde3') +  theme_bw() +
  theme(#axis.title.x=element_blank(),
    axis.ticks.x=element_blank(),
    legend.title=element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank()) +
  labs(y="Number of Player Exports",x="") + theme(legend.position="none")

# ###########################
# Trade Balance
# ###########################

Trade <- fin_df2 %>% select("Birthcountry"=Team,ForeignPlayers) %>% left_join(Expo,by="Birthcountry") %>%
  select(Country=Birthcountry,Imports=`ForeignPlayers`,Exports=Players) %>%
  mutate(`Trade Balance`=Exports-Imports,
         sign = ifelse(`Trade Balance` >= 0, "positive", "negative")) %>%
  arrange(desc(`Trade Balance`)) %>%
  filter(Country %in% target)

Trade_g <- Trade %>%
  ggplot(aes(y=`Trade Balance`, x=reorder(Country,`Trade Balance`),label="",fill=sign)) +
  geom_bar(stat = "identity") + scale_fill_brewer(palette='Pastel1') +
  theme_bw() +
  theme(axis.title.y=element_blank(),
        axis.title.x=element_blank(),
        axis.ticks.y=element_blank(),
        axis.ticks.x=element_blank(),
        legend.title=element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        legend.position="none") +
  coord_flip(ylim = c(-100,200))

# ###########################
# Timeline of Imports
# ###########################

tl <- d %>% group_by(Team,Birthcountry,Debut) %>%
  summarise(Players =n(),Points=sum(Points),Tries=sum(Tries),
            Matches=sum(Matches)) %>% ungroup() %>%
  mutate(Birthcountry = ifelse(is.na(Birthcountry),"Missing",Birthcountry)) %>%
  filter(Team!=Birthcountry,Birthcountry!="Missing",Team %in% target) %>%
  group_by(Debut) %>%
  summarise(Foreign=sum(Players))

tl_g <- ggplot(tl, aes(x=Debut, y=Foreign)) + geom_line(color='lightsteelblue2',size=2) +
  labs(y="Number of Foreign Born Debutants",x="Year") + theme_bw() + ylim(c(0,30)) +
  theme(legend.title=element_blank(),
        legend.position="bottom",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank()
        ) 

# ###########################
# Player Contributions
# ###########################
 
cont <- fin_df2 %>% filter(Team %in% target) %>%
  mutate(NatP = NativePoints/NativePlayers,NatT=NativeTries/NativePlayers,
         NatM=NativeMatches/NativePlayers,
         FP = ForeignPoints/ForeignPlayers,FT=ForeignTries/ForeignPlayers,
         FM = ForeignMatches/ForeignPlayers,
         Team=ifelse(Team=="New Zealand","New&nbsp;Zealand",Team)) %>%
  select(Team,`Points per Native Player`=NatP,`Points per Foreign&nbsp;Player`=FP,
         `Tries per Native Player`=NatT,`Tries per Foreign Player`=FT,
         `Matches per Native Player`=NatM,`Matches per Foreign Player`=FM)

# # Create points/player table etc
# d5 <- d2 %>%
#   mutate(Status=ifelse(is.na(Birthcountry),"Missing",
#                        ifelse(Team==Birthcountry,"Native","Foreign"))) %>%
#   select(-Birthcountry) %>% filter(Status!="Missing",Team %in% COUNTRY) %>%
#   group_by(Team,Status) %>% summarise_each(funs(sum)) %>%
#   mutate(PpP = Points/Players,TpP=Tries/Players,MpP=Matches/Players)
# 
# dpoints <- d5 %>% select(Team,Status,PpP) %>% spread(Status,PpP) %>%
#   select(Team,`Points per Native Player`=Native,`Points per Foreign Player`=Foreign)
# dtries <- d5 %>% select(Team,Status,TpP) %>% spread(Status,TpP) %>%
#   select(Team,`Tries per Native Player`=Native,`Tries per Foreign Player`=Foreign)
# dmatches <- d5 %>% select(Team,Status,MpP) %>% spread(Status,MpP) %>%
#   select(Team,`Matches per Native Player`=Native,`Matches per Foreign Player`=Foreign)
# 
# d6 <- left_join(dmatches,dpoints,by="Team") %>% left_join(dtries,by="Team")
# 
# 



# 
# missingcutoff <- 0.1
# temp <- d3 %>% mutate(MissingRate=ifelse(is.na(`Missing Birth Information`/`Total`)
#                                          ,0,`Missing Birth Information`/`Total`)) %>%
#   filter(MissingRate<=missingcutoff)
# 
# COUNTRY <- d1$Team
# COUNTRY_S <- c(temp$Team,"Samoa","Fiji")
# 
# temp1 <- d2 %>% filter(Team %in% COUNTRY_S) %>%
#   mutate(check=ifelse(Birthcountry %in% COUNTRY_S,Birthcountry,"Other"),
#          check=ifelse(is.na(Birthcountry),"Missing",check)) %>%
#   group_by(Team,check) %>% summarise(Players=sum(Players))
# 
# library(tidyr)
# d_wide <- spread(temp1, check, Players) %>% mutate(missing1=Missing,other1=Other) %>%
#   select(-Missing,-Other) %>% mutate(Other=other1,Missing=missing1) %>%
#   select(-missing1,-other1) %>% left_join(d1,by="Team") %>%
#   mutate(Total=TotalPlayers) %>% select(-TotalPlayers,-TotalPoints,-TotalTries)
# 
# d_wide[is.na(d_wide)] <- 0
# 
# #############
# 
# MissingPlayers <- d %>% filter(Team %in% COUNTRY_S,is.na(Birthcountry)) %>%
#   select(-Birthplace,-Birthcountry)
# 
# #############
# 
# # posies <- d %>% mutate(Status=ifelse(is.na(Birthcountry),"Missing",
# #                                    ifelse(Team==Birthcountry,"Native","Foreign")),
# #                      Position = ifelse(is.na(Position),"Unknown",Position)) %>%
# #   separate(Position,into = c("Position", "Pos2"),sep=",")
# # 
# # d7 <- posies$Position
# # d7[d7=="Wing"|d7=="Outside back"|d7=="Fullback"|d7=="Utility back"|
# #      d7=="Scrum-half"|d7=="Five-eighth"|d7=="Fly-half"|d7=="Halfback"|
# #      d7=="Centre"] <- "Backs"
# # d7[d7=="Lock"|d7=="Front-row"|d7=="Prop"|d7=="Hooker"|
# #      d7=="No. 8"|d7=="Flanker"|d7=="Utility forward"|d7=="Back-row"] <- "Forwards"
# # d7 <- as.data.frame(d7)
# # 
# # posies <- cbind(posies, d7) %>% filter(Status!="Missing") %>%
# #   unite(Status,Status,d7,sep="-") %>%
# #   select(Team,Status) %>% group_by(Team,Status) %>%
# #   summarise(count=n()) %>% spread(Status, count) %>%
# #   mutate(`Native Forward:Back Ratio`=`Native-Forwards`/`Native-Backs`,
# #          `Foreign Forward:Back Ratio`=`Foreign-Forwards`/`Foreign-Backs`) %>%
# #   select(Team,`Native Forward:Back Ratio`,`Foreign Forward:Back Ratio`)
# 
# #############
# 
# Expo <- d %>% filter(Team!=Birthcountry) %>%
#   group_by(Birthcountry) %>%
#   summarise(Players =n(),points=sum(Points),tries=sum(Tries),matches=sum(Matches)) %>%
#   arrange(desc(Players)) %>%
#   mutate(ppp=points/Players,tpp=tries/Players,mpp=matches/Players) %>%
#   select(Birthcountry,`Exported Players`=Players,`Points per Player`=ppp,`Tries per Player`=tpp,
#          `Matches per Player`=mpp) %>% mutate(Team=Birthcountry) 
# 
# d9 <- Expo[,1:2] %>% filter(row_number() <= 12)
# 
# TotalExports <- d %>% filter(Team!=Birthcountry) %>%
#   group_by(Birthcountry) %>% summarise(Players =n()) %>% select(Players) %>%
#   summarise(sum(Players))
# 
# Trade <- d3 %>% select(Team,`Foreign Born`) %>% left_join(Expo,by="Team") %>%
#   select(Team,Imports=`Foreign Born`,Exports=`Exported Players`) %>%
#   mutate(`Trade Balance`=Exports-Imports) %>% arrange(desc(`Trade Balance`))
