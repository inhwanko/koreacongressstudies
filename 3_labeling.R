# Note: This only contains the environmental committee analysis. You can adopt the same structured code for the welfare committee analysis 
# and the analysis of other issue-area committees as well. 

# 1. Load necessary packages


# rm(list=ls())
# install.packages(c("tm","backports","tidyverse","tidytext","topicmodels","stringr","lda"))

library(tidyverse)
library(tidytext)
library(topicmodels)
library(tm)
library(stringr)
library(lda)

Sys.setenv(JAVA_HOME="C:\\Program Files\\Java\\jre1.8.0_261")
# install.packages("rJava")
library(rJava)

# remotes::install_github("haven-jeon/KoNLP", upgrade="never", INSTALL_opts=c("--no-multiarch"))
library(KoNLP)
library(readxl)



# 2. Load data

speech_env16 <- read_excel("env16.csv")[,-1]
speech_env17 <- read_excel("env17.csv")[,-1]
speech_env18 <- read_excel("env18.csv")[,-1]
speech_env19 <- read_excel("env19.csv")[,-1]
speech_env20 <- read_excel("env20.csv")[,-1]


# 3. Operationalize

## 1) Numbering

speech_env16$no <- speech_env17$no <- speech_env18$no <- speech_env19$no <- speech_env20$no <- NA

speech_env16$no <- c(1:nrow(speech_env16)) 
speech_env17$no <- c(1:nrow(speech_env17))
speech_env18$no <- c(1:nrow(speech_env18))
speech_env19$no <- c(1:nrow(speech_env19))
speech_env20$no <- c(1:nrow(speech_env20))


## 2) Legislator or not (1-0)- binary

speech_env16$legis <- speech_env17$legis <- speech_env18$legis <- speech_env19$legis <- speech_env20$legis <- 0

for (i in 1:nrow(speech_env16)) {
  speech_env16$legis[i] <- ifelse(
   sum(grep("의원", speech_env16$speaker[i]))==1 |
   sum(grep("위원", speech_env16$speaker[i]))==1 |
   sum(grep("위원장", speech_env16$speaker[i]))==1 |
   sum(grep("委員", speech_env16$speaker[i]))==1 |
   sum(grep("議員", speech_env16$speaker[i]))==1 |
   sum(grep("議員長", speech_env16$speaker[i]))==1 |
   sum(grep("위원장대리", speech_env16$speaker[i]))==1 |
   sum(grep("議員長代理", speech_env16$speaker[i]))==1, 
  1,0
 )
}

for (i in 1:nrow(speech_env17)) {
  speech_env17$legis[i] <- ifelse(
   sum(grep("의원", speech_env17$speaker[i]))==1 |
   sum(grep("위원", speech_env17$speaker[i]))==1 |
   sum(grep("위원장", speech_env17$speaker[i]))==1 |
   sum(grep("委員", speech_env17$speaker[i]))==1 |
   sum(grep("議員", speech_env17$speaker[i]))==1 |
   sum(grep("議員長", speech_env17$speaker[i]))==1 |
   sum(grep("위원장대리", speech_env17$speaker[i]))==1 |
   sum(grep("議員長代理", speech_env17$speaker[i]))==1, 
  1,0
 )
}

for (i in 1:nrow(speech_env18)) {
  speech_env18$legis[i] <- ifelse(
   sum(grep("의원", speech_env18$speaker[i]))==1 |
   sum(grep("위원", speech_env18$speaker[i]))==1 |
   sum(grep("위원장", speech_env18$speaker[i]))==1 |
   sum(grep("委員", speech_env18$speaker[i]))==1 |
   sum(grep("議員", speech_env18$speaker[i]))==1 |
   sum(grep("議員長", speech_env18$speaker[i]))==1 |
   sum(grep("위원장대리", speech_env18$speaker[i]))==1 |
   sum(grep("議員長代理", speech_env18$speaker[i]))==1, 
  1,0
 )
}

for (i in 1:nrow(speech_env19)) {
  speech_env19$legis[i] <- ifelse(
   sum(grep("의원", speech_env19$speaker[i]))==1 |
   sum(grep("위원", speech_env19$speaker[i]))==1 |
   sum(grep("위원장", speech_env19$speaker[i]))==1 |
   sum(grep("委員", speech_env19$speaker[i]))==1 |
   sum(grep("議員", speech_env19$speaker[i]))==1 |
   sum(grep("議員長", speech_env19$speaker[i]))==1 |
   sum(grep("위원장대리", speech_env19$speaker[i]))==1 |
   sum(grep("議員長代理", speech_env19$speaker[i]))==1, 
  1,0
 )
}

for (i in 1:nrow(speech_env20)) {
  speech_env20$legis[i] <- ifelse(
   sum(grep("의원", speech_env20$speaker[i]))==1 |
   sum(grep("위원", speech_env20$speaker[i]))==1 |
   sum(grep("위원장", speech_env20$speaker[i]))==1 |
   sum(grep("委員", speech_env20$speaker[i]))==1 |
   sum(grep("議員", speech_env20$speaker[i]))==1 |
   sum(grep("議員長", speech_env20$speaker[i]))==1 |
   sum(grep("위원장대리", speech_env20$speaker[i]))==1 |
   sum(grep("議員長代理", speech_env20$speaker[i]))==1, 
  1,0
 )
}

sum(speech_env16$legis) #10984 / 18335, 0.5990
sum(speech_env17$legis) #22697 / 35141, 0.6458
sum(speech_env18$legis) #24635 / 38282, 0.6435
sum(speech_env19$legis) #41138 / 63451, 0.6483
sum(speech_env20$legis) #16241 / 24628, 0.6594



## 3) Interruption (by parcing out "......")

speech_env16$interrupt <- speech_env17$interrupt <- speech_env18$interrupt <- speech_env19$interrupt <- speech_env20$interrupt <- NA

speech_env16$interrupt[1] <- speech_env17$interrupt[1] <- speech_env18$interrupt[1] <- speech_env19$interrupt[1] <- speech_env20$interrupt[1] <- 0

for (i in 2:length(speech_env16$speech)) {
  speech_env16$interrupt[i] <- ifelse(
   sum(grep("……$", speech_env16$speech[i-1]))==1, 
   1, 0
   )
}

for (i in 2:length(speech_env17$speech)) {
  speech_env17$interrupt[i] <- ifelse(
   sum(grep("……$", speech_env17$speech[i-1]))==1, 
   1, 0
   )
}

for (i in 2:length(speech_env18$speech)) {
  speech_env18$interrupt[i] <- ifelse(
   sum(grep("……$", speech_env18$speech[i-1]))==1, 
   1, 0
   )
}

for (i in 2:length(speech_env19$speech)) {
  speech_env19$interrupt[i] <- ifelse(
   sum(grep("……$", speech_env19$speech[i-1]))==1, 
   1, 0
   )
}

for (i in 2:length(speech_env20$speech)) {
  speech_env20$interrupt[i] <- ifelse(
   sum(grep("……$", speech_env20$speech[i-1]))==1, 
   1, 0
   )
}

sum(speech_env16$interrupt[speech_env16$legis==1])
sum(speech_env17$interrupt[speech_env17$legis==1])
sum(speech_env18$interrupt[speech_env18$legis==1])
sum(speech_env19$interrupt[speech_env19$legis==1])
sum(speech_env20$interrupt[speech_env20$legis==1])


## 4) Blaming (using dictionary method) 

speech_env16$blame <- speech_env17$blame <- speech_env18$blame <- speech_env19$blame <- speech_env20$blame <- 0

for (i in 1:nrow(speech_env16)) {
  speech_env16$blame[i] <- ifelse(
   sum(grep("바보", speech_env16$speech[i]))==1 |
   sum(grep("멍청", speech_env16$speech[i]))==1 |
   sum(grep("무식", speech_env16$speech[i]))==1 |
   sum(grep("경박", speech_env16$speech[i]))==1 |
   sum(grep("인격", speech_env16$speech[i]))==1, 
  1,0
 )
}

for (i in 1:nrow(speech_env17)) {
  speech_env17$blame[i] <- ifelse(
   sum(grep("바보", speech_env17$speech[i]))==1 |
   sum(grep("멍청", speech_env17$speech[i]))==1 |
   sum(grep("무식", speech_env17$speech[i]))==1 |
   sum(grep("경박", speech_env17$speech[i]))==1 |
   sum(grep("인격", speech_env17$speech[i]))==1, 
  1,0
 )
}
for (i in 1:nrow(speech_env18)) {
  speech_env18$blame[i] <- ifelse(
   sum(grep("바보", speech_env18$speech[i]))==1 |
   sum(grep("멍청", speech_env18$speech[i]))==1 |
   sum(grep("무식", speech_env18$speech[i]))==1 |
   sum(grep("경박", speech_env18$speech[i]))==1 |
   sum(grep("인격", speech_env18$speech[i]))==1, 
  1,0
 )
}
for (i in 1:nrow(speech_env19)) {
  speech_env19$blame[i] <- ifelse(
   sum(grep("바보", speech_env19$speech[i]))==1 |
   sum(grep("멍청", speech_env19$speech[i]))==1 |
   sum(grep("무식", speech_env19$speech[i]))==1 |
   sum(grep("경박", speech_env19$speech[i]))==1 |
   sum(grep("인격", speech_env19$speech[i]))==1, 
  1,0
 )
}
for (i in 1:nrow(speech_env20)) {
  speech_env20$blame[i] <- ifelse(
   sum(grep("바보", speech_env20$speech[i]))==1 |
   sum(grep("멍청", speech_env20$speech[i]))==1 |
   sum(grep("무식", speech_env20$speech[i]))==1 |
   sum(grep("경박", speech_env20$speech[i]))==1 |
   sum(grep("인격", speech_env20$speech[i]))==1, 
  1,0
 )
}

sum(speech_env16$blame[speech_env16$legis==1])
sum(speech_env17$blame[speech_env17$legis==1])
sum(speech_env18$blame[speech_env18$legis==1])
sum(speech_env19$blame[speech_env19$legis==1])
sum(speech_env20$blame[speech_env20$legis==1])


## 5) Criticizing the assembly

speech_env16$critique <- speech_env17$critique <- speech_env18$critique <- speech_env19$critique <- speech_env20$critique <- 0

for (i in 1:nrow(speech_env16)) {
  speech_env16$critique[i] <- ifelse(
   sum(grep("파행", speech_env16$speech[i]))==1 |
   sum(grep("막장", speech_env16$speech[i]))==1 |
   sum(grep("전횡", speech_env16$speech[i]))==1 |
   sum(grep("독단", speech_env16$speech[i]))==1 |
   sum(grep("날치기", speech_env16$speech[i]))==1 |
   sum(grep("깽판", speech_env16$speech[i]))==1  , 
  1,0
 )
}

for (i in 1:nrow(speech_env17)) {
  speech_env17$critique[i] <- ifelse(
   sum(grep("파행", speech_env16$speech[i]))==1 |
   sum(grep("막장", speech_env16$speech[i]))==1 |
   sum(grep("전횡", speech_env16$speech[i]))==1 |
   sum(grep("독단", speech_env16$speech[i]))==1 |
   sum(grep("날치기", speech_env16$speech[i]))==1 |
   sum(grep("깽판", speech_env16$speech[i]))==1  , 
  1,0
 )
}
for (i in 1:nrow(speech_env18)) {
  speech_env18$critique[i] <- ifelse(
   sum(grep("파행", speech_env16$speech[i]))==1 |
   sum(grep("막장", speech_env16$speech[i]))==1 |
   sum(grep("전횡", speech_env16$speech[i]))==1 |
   sum(grep("독단", speech_env16$speech[i]))==1 |
   sum(grep("날치기", speech_env16$speech[i]))==1 |
   sum(grep("깽판", speech_env16$speech[i]))==1  , 
  1,0
 )
}
for (i in 1:nrow(speech_env19)) {
  speech_env19$critique[i] <- ifelse(
   sum(grep("파행", speech_env16$speech[i]))==1 |
   sum(grep("막장", speech_env16$speech[i]))==1 |
   sum(grep("전횡", speech_env16$speech[i]))==1 |
   sum(grep("독단", speech_env16$speech[i]))==1 |
   sum(grep("날치기", speech_env16$speech[i]))==1 |
   sum(grep("깽판", speech_env16$speech[i]))==1  , 
  1,0
 )
}
for (i in 1:nrow(speech_env20)) {
  speech_env20$critique[i] <- ifelse(
   sum(grep("파행", speech_env16$speech[i]))==1 |
   sum(grep("막장", speech_env16$speech[i]))==1 |
   sum(grep("전횡", speech_env16$speech[i]))==1 |
   sum(grep("독단", speech_env16$speech[i]))==1 |
   sum(grep("날치기", speech_env16$speech[i]))==1 |
   sum(grep("깽판", speech_env16$speech[i]))==1  , 
  1,0
 )
}

sum(speech_env16$critique[speech_env16$legis==1])
sum(speech_env17$critique[speech_env17$legis==1])
sum(speech_env18$critique[speech_env18$legis==1])
sum(speech_env19$critique[speech_env19$legis==1])
sum(speech_env20$critique[speech_env20$legis==1])


## 6) Criticizing the government

speech_env16$critgov <- speech_env17$critgov <- speech_env18$critgov <- speech_env19$critgov <- speech_env20$critgov <- 0

for (i in 1:nrow(speech_env16)) {
  speech_env16$critgov[i] <- ifelse(
   sum(grep("독재", speech_env16$speech[i]))==1 |
   sum(grep("사퇴", speech_env16$speech[i]))==1, 
  1,0
 )
}

for (i in 1:nrow(speech_env17)) {
  speech_env17$critgov[i] <- ifelse(
   sum(grep("독재", speech_env16$speech[i]))==1 |
   sum(grep("사퇴", speech_env16$speech[i]))==1, 
  1,0
 )
}
for (i in 1:nrow(speech_env18)) {
  speech_env18$critgov[i] <- ifelse(
   sum(grep("독재", speech_env16$speech[i]))==1 |
   sum(grep("사퇴", speech_env16$speech[i]))==1, 
  1,0
 )
}
for (i in 1:nrow(speech_env19)) {
  speech_env19$critgov[i] <- ifelse(
   sum(grep("독재", speech_env16$speech[i]))==1 |
   sum(grep("사퇴", speech_env16$speech[i]))==1, 
  1,0
 )
}
for (i in 1:nrow(speech_env20)) {
  speech_env20$critgov[i] <- ifelse(
   sum(grep("독재", speech_env16$speech[i]))==1 |
   sum(grep("사퇴", speech_env16$speech[i]))==1, 
  1,0
 )
}

sum(speech_env16$critgov[speech_env16$legis==1])
sum(speech_env17$critgov[speech_env17$legis==1])
sum(speech_env18$critgov[speech_env18$legis==1])
sum(speech_env19$critgov[speech_env19$legis==1])
sum(speech_env20$critgov[speech_env20$legis==1])



## 7) Total condemnation

speech_env16$totalcondemn <- speech_env17$totalcondemn <- speech_env18$totalcondemn <- speech_env19$totalcondemn <- speech_env20$totalcondemn <- 0

for (i in 1:nrow(speech_env16)) {
  speech_env16$totalcondemn[i] <- ifelse(
   speech_env16$blame[i]==1 |
   speech_env16$critique[i]==1 |
   speech_env16$critgov[i]==1 |
   speech_env16$misinfo[i]==1,
  1,0
 )
}

for (i in 1:nrow(speech_env17)) {
  speech_env17$totalcondemn[i] <- ifelse(
   speech_env17$blame[i]==1 |
   speech_env17$critique[i]==1 |
   speech_env17$critgov[i]==1 |
   speech_env17$misinfo[i]==1,
  1,0
 )
}
for (i in 1:nrow(speech_env18)) {
  speech_env18$totalcondemn[i] <- ifelse(
   speech_env18$blame[i]==1 |
   speech_env18$critique[i]==1 |
   speech_env18$critgov[i]==1 |
   speech_env18$misinfo[i]==1,
  1,0
 )
}
for (i in 1:nrow(speech_env19)) {
  speech_env19$totalcondemn[i] <- ifelse(
   speech_env19$blame[i]==1 |
   speech_env19$critique[i]==1 |
   speech_env19$critgov[i]==1 |
   speech_env19$misinfo[i]==1,
  1,0
 )
}
for (i in 1:nrow(speech_env20)) {
  speech_env20$totalcondemn[i] <- ifelse(
   speech_env20$blame[i]==1 |
   speech_env20$critique[i]==1 |
   speech_env20$critgov[i]==1 |
   speech_env20$misinfo[i]==1,
  1,0
 )
}

sum(speech_env16$totalcondemn[speech_env16$legis==1])
sum(speech_env17$totalcondemn[speech_env17$legis==1])
sum(speech_env18$totalcondemn[speech_env18$legis==1])
sum(speech_env19$totalcondemn[speech_env19$legis==1])
sum(speech_env20$totalcondemn[speech_env20$legis==1])



### Save all outputs into csv file, such as:

write.csv(speech_env16, "legis_env16.csv")

