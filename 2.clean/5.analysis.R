# This program performs the final analysis
library(data.table)
library(stargazer)
library(ggplot2)

# Load datasets
d       <- read.csv("../final_data.csv", header=TRUE,stringsAsFactors=F)
country <- read.csv("manual_adjustments/country_codes.csv", header=FALSE,stringsAsFactors=F)

# Restrict by year
d <- d[d$debut>1995,]
d <- d[complete.cases(d$debut),]

# Define countries of analysis
COUNTRIES <- c("England","Australia","Scotland","Wales","SouthAfrica","Ireland",
               "NewZealand","France","Argentina","Italy","Samoa","Tonga")
clist <- c("ENG","AUS","SCO","WAL","SA","IRE","NZ","FR","ARG","ITA","SAM","TON","USA","NAMIBIA","")

# Create counts of birthplaces
df <- data.frame(matrix(nrow = length(COUNTRIES), ncol = length(clist)))
colnames(df)<-clist
rownames(df)<-COUNTRIES
sum_df<-data.frame(matrix(nrow=length(COUNTRIES), ncol=1))
colnames(sum_df)<-c("Total")

for (i in 1:length(COUNTRIES)){
  sum_df[i,1] <- sum(d$team==COUNTRIES[i],na.rm = T)
  for (j in 1:length(clist)){
    df[i,j]<-sum(d$country[d$team==COUNTRIES[i]]==clist[j],na.rm = T)
  }
}

df <- transform(df, Other=sum_df$Total-rowSums(df))

# Create sums of points scored
df_points <- data.frame(matrix(nrow = length(COUNTRIES), ncol = length(clist)))
colnames(df_points)<-clist
rownames(df_points)<-COUNTRIES
sum_df_points<-data.frame(matrix(nrow=length(COUNTRIES), ncol=1))

colnames(sum_df_points)<-c("Total")
for (i in 1:length(COUNTRIES)){
  sum_df_points[i,1] <- sum(d$tries[d$team==COUNTRIES[i]],na.rm = T)
  for (j in 1:length(clist)){
    df_points[i,j] <- sum(d$tries[d$country==clist[j]&d$team==COUNTRIES[i]],na.rm = TRUE)
  }
}

df_points <- transform(df_points, Other=sum_df_points$Total-rowSums(df_points))

# Create sums of tests played
df_tests <- data.frame(matrix(nrow = length(COUNTRIES), ncol = length(clist)))
colnames(df_tests)<-clist
rownames(df_tests)<-COUNTRIES
sum_df_tests<-data.frame(matrix(nrow=length(COUNTRIES), ncol=1))

colnames(sum_df_tests)<-c("Total")
for (i in 1:length(COUNTRIES)){
  sum_df_tests[i,1] <- sum(d$tests[d$team==COUNTRIES[i]],na.rm = T)
  for (j in 1:length(clist)){
    df_tests[i,j] <- sum(d$tests[d$country==clist[j]&d$team==COUNTRIES[i]],na.rm = TRUE)
  }
}

df_tests <- transform(df_tests, Other=sum_df_tests$Total-rowSums(df_tests))

# Analysis
Migration <- df[,1:length(COUNTRIES)]
Migration$Other <- df$Other
Migration$Missing <- df$Var.15
Migration$sum <- rowSums(Migration)

Imports_players <- rowSums(df[,1:length(COUNTRIES)])-diag(as.matrix(df))
Exports_players <- colSums(df[,1:length(COUNTRIES)])-diag(as.matrix(df))

Imports_points <- rowSums(df_points[,1:length(COUNTRIES)])-diag(as.matrix(df_points))
Exports_points <- colSums(df_points[,1:length(COUNTRIES)])-diag(as.matrix(df_points))

Imports_tests <- rowSums(df_tests[,1:length(COUNTRIES)])-diag(as.matrix(df_tests))
Exports_tests <- colSums(df_tests[,1:length(COUNTRIES)])-diag(as.matrix(df_tests))

Exports <- data.frame(Exports_players, Exports_points, Exports_tests)
Imports <- data.frame(Imports_players, Imports_points, Imports_tests)

stargazer(Exports,type="text",title = "Contribution toward Foreign nations",style="aer",
          notes = "Source: Author's construction",flip=FALSE,summary=FALSE,out="output/Exports.tex")

stargazer(Exports,type="text",title = "Contribution toward Foreign nations",style="aer",
          notes = "Source: Author's construction",flip=FALSE,summary=FALSE,out="output/Exports.txt")

stargazer(Exports,type="text",title = "Contribution toward Foreign nations",style="aer",
          notes = "Source: Author's construction",flip=FALSE,summary=FALSE,out="output/Exports.html")

stargazer(Imports,type="text",title = "Contribution of Foreign-Born Players",style="aer",
          notes = "Source: Author's construction",flip=FALSE,summary=FALSE,out="output/Imports.tex")

stargazer(Migration,type="text",title = "Player Birthplace for Each Team",style="aer",
          notes = "A count of the birthplace(columns) of players from each country (row).",
          flip=FALSE,summary=FALSE,dep.var.labels = "Hi",out="output/Migration.tex")

stargazer(Migration,type="text",title = "Player Birthplace for Each Team",style="aer",
          notes = "A count of the birthplace(columns) of players from each country (row).",
          flip=FALSE,summary=FALSE,dep.var.labels = "Hi",out="output/Migration.txt")

# Time Series
YEAR <- unique(d$debut)
history_Tot <- data.frame(matrix(nrow = length(COUNTRIES), ncol = length(YEAR)))
colnames(history_Tot)<-YEAR
rownames(history_Tot)<-COUNTRIES
history_Mig <- history_Tot

for (i in 1:length(COUNTRIES)){
  for (j in 1:length(YEAR)){
    history_Mig[i,j] <- length(d$player[d$debut==YEAR[j] & d$team==COUNTRIES[i] & d$country!=clist[i]])
    history_Tot[i,j] <- length(d$player[d$debut==YEAR[j] & d$team==COUNTRIES[i]])
  }
}

history_Tot$sum <- rowSums(history_Tot)

tseries<-data.frame(t(history_Tot[,1:ncol(history_Tot)-1]))
tseries1<-data.frame(t(history_Mig[,1:ncol(history_Mig)-1]))

plot(rownames(tseries), tseries$England,col="red")
lines(rownames(tseries), tseries$NewZealand,col="black")
lines(rownames(tseries), tseries$Australia,col="green")

a<-ggplot(data=tseries, aes(x=rownames(tseries),group=1)) + 
  geom_line(aes( y=tseries$England),colour="red",linetype="dashed", size=1.5) + 
  geom_line(aes( y=tseries$NewZealand),colour="black") + 
  xlab("Year") + ylab("Number of debutants") +
  ggtitle("Number of debutants per Year")

a
  
