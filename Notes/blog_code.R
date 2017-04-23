## @knitr main
# This program "tests" code used in writeup

library(readr)
library(dplyr)
library(ascii)
library(readxl)
library("RColorBrewer")
cutoff <- 1995

target <-  c("Argentina","Australia","England","France","Ireland","New Zealand",
             "Scotland","South Africa","Wales","Italy")

# Choose color Palette
colorchoice <- brewer.pal(3, "Pastel1")

# Load player data
d <- read_csv("../data/1.main_data.csv") %>%
  as.data.frame() %>% filter(Debut>cutoff) %>%
  mutate(Team = ifelse(Team=="SouthAfrica","South Africa",Team),
         Birthcountry = ifelse(Birthcountry=="SouthAfrica","South Africa",Birthcountry),
         Team = ifelse(Team=="NewZealand","New Zealand",Team),
         Birthcountry = ifelse(Birthcountry=="NewZealand","New Zealand",Birthcountry)) %>%
  mutate(Points=ifelse(is.na(Points),0,Points))

han <- read_csv("../data/1.main_data.csv") %>% as.data.frame() %>%
  mutate(Team = ifelse(Team=="SouthAfrica","South Africa",Team),
         Birthcountry = ifelse(Birthcountry=="SouthAfrica","South Africa",Birthcountry),
         Team = ifelse(Team=="NewZealand","New Zealand",Team),
         Birthcountry = ifelse(Birthcountry=="NewZealand","New Zealand",Birthcountry)) %>%
  select(-Position,-Wins,-Losses,-Draws) %>% filter(Debut>1900) %>% arrange(-Debut) %>%
  filter(Team %in% target) #%>%
  # mutate(Birthplace = ifelse(Birthplace=="",Birthcountry,paste(Birthplace,Birthcountry,sep=", "))) %>%
  # select(-Birthcountry)
  

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
  melt(id.vars = "Team", measure.vars = c("Native Players", "Foreign Players")) %>%
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
  select(`Country` = `Country Name`,`Foreign born Population (%)`=`2015 [YR2015]`) %>%
  filter(!is.na(Country))

m$Country[m$Country=="United States"]="USA"

UK_data<- m %>% filter(Country=="United Kingdom") %>% select(`Foreign born Population (%)`)
UK_data <- UK_data[1,1]

temp <- data_frame("Country"=c("England","Wales","Scotland"),
                   "Foreign born Population (%)"=c(UK_data,UK_data,UK_data))

m1 <- m %>% rbind(temp) %>% mutate(Team=Country) %>% 
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

# Expo <- fin_df %>% filter(Team %in% target,Team!=Birthcountry) %>%
#   group_by(Birthcountry) %>%
#   summarise(Players =n(),points=sum(Points),tries=sum(Tries),matches=sum(Matches)) %>%
#   arrange(desc(Players),Birthcountry)

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
  summarise(Foreign=sum(Players)) %>%
  filter(Debut!=2017)

tl_g <- tl  %>% ggplot( aes(x=Debut, y=Foreign)) + geom_line(color='lightsteelblue2',size=2) +
  labs(y="Number of Foreign Born Debutants",x="Year") + theme_bw() + ylim(c(0,40)) +
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

# ###########################
# Pacific Island Data
# ###########################


# Read UN Data
UNdata <- read_excel("../data/UN_MigrantStockByOriginAndDestination_2015.xlsx",
                     sheet = "Table 16",range = "B16:IF281")

# Read World Bank Population Data
Wpop <- read.csv("../data/WorldBankData/World_Population.csv",skip = 4,stringsAsFactors = F) %>%
  select(country=X.3,population=X.4) %>%
  mutate(population=as.numeric(as.numeric(gsub(",", "", population)))*1000)

targetUN <-  c("Argentina","Australia","France","Ireland","New Zealand","South Africa",
               "Italy","United Kingdom of Great Britain and Northern Ireland")

UN <- UNdata %>% select(country=X__1,Samoa,Fiji,Tonga) %>%
  filter(country %in% targetUN) %>%
  mutate(country=ifelse(country=="United Kingdom of Great Britain and Northern Ireland","United Kingdom",country)) %>%
  left_join(Wpop,by="country") %>%
  rowwise() %>%
  mutate(`Pacific Islands`=sum(Samoa,Fiji,Tonga,na.rm=TRUE)/population*100,
         Samoa=Samoa/population*100,
         Fiji=Fiji/population*100,
         Tonga=Tonga/population*100)

UKdata <- UN %>% filter(country=="United Kingdom") %>%
  data.frame(matrix(rep(.,each=3),nrow=3)) %>% select(1:6) %>%
  mutate(country=c("England","Scotland","Wales"),
         `Pacific Islands`=Pacific.Islands) %>%
  select(-Pacific.Islands)

UN <- UN %>% rbind(UKdata) %>%
  filter(country!="United Kingdom")

# Create Full Data Frame of Pacific Players
PI = c("Samoa","Tonga","Fiji")

PI_df <- fin_df %>%
  filter(Birthcountry %in% PI,Team %in% target) %>%
  group_by(Team) %>%
  summarize(`Pacific Island Players`=sum(Players),
            TotalPlayers=mean(TotalPlayers)) %>%
  filter(`Pacific Island Players`>2) %>%
  mutate(PI=`Pacific Island Players`/TotalPlayers*100) %>%
  left_join(UN,by = c("Team" = "country")) %>%
  mutate(ratio=PI/`Pacific Islands`,
         Team=c("Aus","Eng","NZ"))

NZ_df <- fin_df %>%
  filter(Birthcountry=="New Zealand",Team %in% target,Team!="New Zealand")

g_NZ <- NZ_df %>% ggplot( aes(x=reorder(Team, -`Players`), y=Players)) +
  geom_bar(stat='identity',position='dodge',fill=colorchoice[1]) + # scale_fill_brewer(palette='Pastel1') +
  labs(y="New Zealand Born Players",x="") + theme_bw() +
  theme(legend.title=element_blank(),
        legend.position="bottom",
        axis.ticks.x=element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank()) 

PI_g <- PI_df %>% ggplot( aes(x=Team, y=`Pacific Island Players`)) +
  geom_bar(stat='identity',position='dodge',fill=colorchoice[2]) + # scale_fill_brewer(palette='Pastel1') +
  labs(y="Number of Pacific Players",x="") + theme_bw() + coord_cartesian(ylim = c(0, 25)) +
  theme(legend.title=element_blank(),
        legend.position="bottom",
        axis.ticks.x=element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank()) 

PIpop_g <- PI_df %>% ggplot(aes(x=Team, y=`Pacific Islands`)) +
  geom_bar(stat='identity',position='dodge',fill=colorchoice[1]) + 
  labs(y="Pacific Born Population (%)",x="") + theme_bw() + 
  coord_cartesian(ylim = c(0, 3)) +
  theme(legend.title=element_blank(),
        legend.position="bottom",
        axis.ticks.x=element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank()) 

PIratio_g <- PI_df %>% ggplot( aes(x=Team, y=ratio)) +
  geom_bar(stat='identity',position='dodge',fill='#b3cde3') + # scale_fill_brewer(palette='Pastel1') +
  labs(y="Pacific Player:Population Ratio",x="") + theme_bw() + 
  theme(legend.title=element_blank(),
        legend.position="bottom",
        axis.ticks.x=element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank()) 

PI_temp <- PI_df %>%
  melt(id.vars = "Team", 
       measure.vars = c("PI", "Pacific Islands"))

g_PIcompare <- ggplot(PI_temp, aes(x=Team, y=value, fill=variable)) +
  geom_bar(stat='identity',position='dodge') +
  scale_fill_brewer(palette='Pastel1',labels=c('Pacific Island Players (%)','Pacific Island Population (%)')) +
  labs(y="Pacific Island Born (%)",x="") + theme_bw() +
  theme(legend.title=element_blank(),
        legend.position="bottom",
        axis.ticks.x=element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank()) 