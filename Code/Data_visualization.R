# final_project_dataVisualization, R코드 밑에 자동화과정 설명.

R코드:

library(RSelenium)  
library(stringi)  
library(stringr)  
require(rvest)  
require(lubridate)  
library(ggplot2)  
require(lubridate)  



folder <- 'd:/laptop_company_data'

if(!dir.exists(folder)) dir.create(folder)

setwd(folder)

date <- Sys.Date()

h <- hour(Sys.time())  
m <- minute(Sys.time())

now <- paste(date, h, m, sep='-')  
now.folder <- paste(folder, now, sep='/')

if(!dir.exists(now.folder)) dir.create(now.folder)

setwd(now.folder)   

url='https://www.amazon.com/Best-Sellers-Computers-Accessories-Traditional-Laptop/zgbs/pc/13896615011/ref=zg_bs_pg_1?_encoding=UTF8&pg='  

page=1:2

pages=paste0(url, page, sep='')

file.name <- paste0('page', page, '.txt')

for(i in 1:length(pages)){  
  file <- read_html(pages[i]) 
    
  write_xml(file, file = file.name[i])  
}

extract = function(file) {  
  html <- read_html(file)   
  table <- html %>% html_nodes("table")  
  td <- table %>% html_nodes("td")   
  text <- td %>% html_text()   
  text <- gsub("(\r)(\n)(\t)*", "", text)  
  df <- as.data.frame(matrix(text, nrow=10, ncol=6, byrow=TRUE))  
    
  link <- html %>% html_nodes("a.hover-link")  
  dataIdx <- gsub("<a.\*dataIdx=|&.\*", "", link)  
  dataIdx <- dataIdx[c(TRUE, FALSE)]  
  df <- cbind(df, dataIdx)  
}

result <- lapply(file.name, extract)  
do.call(rbind, result)











remDr <- remoteDriver(  
  remoteServerAddr = "localhost",  
  port = 4446L,  
  browserName = "chrome"  
)


url <- "https://www.amazon.com/Best-Sellers-Computers-Accessories-Traditional-Laptop/zgbs/pc/13896615011/ref=zg_bs_pg_1?_encoding=UTF8&pg="  
page_to_max <- 1:2  

page_total <- paste(url,page_to_max)  
resHeaders <- vector("character",0)







remDr$open()





#각 페이지에서 제품명부분에 해당하는 부분을 가져온다.  
for(i in page_total){  
  remDr$navigate(i)  
  webElems <- remDr$findElements(using = "css selector", "li.zg-item-immersion")  
  resHeaders <- c(resHeaders,unlist(lapply(webElems, function(x) {x$getElementText()})))  
}








#1. 각각의 필요없는 패턴들을 모두 제거하고 정렬한다.



#resHeaders에서 제품번호까지 삭제한다.  
a <- gsub("#[0-9]+[0-9]+(\n)","",resHeaders) #10의 자리 제품번호 삭제  
b <- gsub("#[0-9]+(\n)","",a) # 1의자리 제품번호 삭제


#벡터에서 New(NEW)가 있는 원소의 위치를 찾아내어 처음에 New(est)를 모두 삭제한다. 단, 제품명에 New가 있을수있으니 처음 11개까지만 검사해서 있을때 제거한다.  
b[str_which(substr(b,1,11),"New")] <- str_replace(b[str_which(substr(b,1,11),"New")],"New(.\*?) ","") #New~~~ 패턴을 따로 제거한다.  
b[str_which(substr(b,1,11),"NEW")] <- str_replace(b[str_which(substr(b,1,11),"New")],"NEW(.\*?) ","") #NEW~~~ 패턴을 따로 제거한다.  
b <- ifelse(substr(b,1,1)==" ",sub(" ","",b),b)




#위와 마찬가지로 필요없는 패턴들(년도, 느낌표 등등)을 모두 제거한다.  
quite_clean_data <- ifelse(  substr(b,1,4) == 2019 | substr(b,1,4) == 2018 | substr(b,1,4) == 2020  , str_sub(b,5,-1)  ,  b <- b) #맨앞에 제조회사가 나오도록 몇몇 데이터의 앞의 날짜삭제  
quite_clean_data <- gsub('!',"",quite_clean_data)  
quite_clean_data[str_which(quite_clean_data,"Flagship")] <- str_replace(quite_clean_data[str_which(quite_clean_data,"Flagship")],"Flagship","") #성능(Flagship)이 앞에 먼저 나온 것도 제거  
quite_clean_data <- gsub("[0-9]+ offers from ","",quite_clean_data) #통상적인 가격비교가 목적이므로 다른 offer는 무시한다.  
quite_clean_data <- gsub("[0-9]+[0-9]+ offers from ","",quite_clean_data)   
quite_clean_data <- gsub("[0-9]+ offer from ","",quite_clean_data)  
quite_clean_data <- gsub("[0-9]+[0-9]+ offers from ","",quite_clean_data)  



#앞의 띄어쓰기 된것을 맨 앞으로 붙인다.  
quite_clean_data <- ifelse(substr(quite_clean_data,1,1)==" ",sub("  &nbsp;","",quite_clean_data),quite_clean_data)  
Step_1 <- ifelse(substr(quite_clean_data,1,1)==" ",sub(" ","",quite_clean_data),quite_clean_data) 








#2. 필요없는 패턴 제거작업 후, 각각의 항목 나누기

#처음 띄어쓰기 된 곳은 회사명과 제품명을 구분하는 기준이 된다. 따라서, 원소별로 띄어쓰기된 곳들의 위치를 모두 찾아낸다.  
loc <- str_locate(pattern = " ",Step_1)

NOC <- vector("character",0)

#회사명을 NOC벡터에 따로 저장한다. substr로 처음부터 loc로 구분한 지점까지 갈라내어 저장한다.  
for(i in 1 : 100){  
  NOC <- c(NOC,substr(Step_1[i],1,loc[i]-1)) #loc에 -1을 한 이유는 space(공백)를 없애기 위한 것이다.  
}



#본래 문자열에서 회사는 이미 저장해 뒀으므로 회사를 제외한 나머지 항목들을 Step_2에 나타낸다.  
Step_2 <- vector("character",0)

for(i in 1:100){  
  Step_2 <- c(Step_2,str_sub(Step_1[i],loc[i]+1,-1))  
}

#각각의 항목들이 \n로 나누어져있다. 이것을 구분 기준으로 삼는다. \n의 처리가 쉽지 않아 구분기준을 " &nbsp;&nbsp;&nbsp;"로 나눈다.  
Step_2 <- gsub("(\n)","    &nbsp;&nbsp;&nbsp;",Step_2) #구분기준을 space 4개로 나눈다.


#각각 원소들의 구분기준 지점의 위치를 저장한다.  
loc_produ <- str_locate(pattern = "    &nbsp;&nbsp;&nbsp;",Step_2)

product <- vector("character",0)

#회사명과 마찬가지로 구분기준까지 나눠서 product라는 항목에 제품명을 따로 저장한다.  
for(i in 1:100){  
  product <- c(product , str_sub(Step_2[i],1,loc_produ[i]))  
}




#위와 같은과정을 모든 항목에 대해서 나눌때 까지 실행한다.  
Step_3 <- vector("character",0)  
for(i in 1:100){  
  Step_3 <- c(Step_3 , str_sub(Step_2[i],loc_produ[i]+4,-1))  
}


Step_3 <- ifelse(!grepl("    &nbsp;&nbsp;&nbsp;", Step_3),paste("    &nbsp;&nbsp;&nbsp;",Step_3),Step_3)

loc_num <- str_locate(pattern = "    &nbsp;&nbsp;&nbsp;",Step_3)  

NON <- vector("character",0) # Name Of Number

for(i in 1:100){  
  NON <- c(NON, str_sub(Step_3[i],1,loc_num[i]-1) )  
}

price <- vector("character",0)  
for(i in 1:100){  
  price <- c(price , str_sub(Step_3[i],loc_num[i]+4,-1))  
}  
price <- ifelse(substr(price,1,1)==" ",sub(" ","",price),price)  
NON <- ifelse(substr(NON,1,1)=="",sub("","0",NON),NON)  



rank=1:100  



#나눈 항목들을 가지고 노트북에 관한 데이터 프레임을 만든다.   
labtops <- as.data.frame(cbind(rank,NOC,product,NON,price))


#데이터 프레임으로 변환할때, 변수들의 상태가 Factor가 된다. 통계량을 계산하기 위해 각각의 항목들을 Factor에서 numeric으로 변환한다.  
stringprice <- gsub("\\\\$", "",labtops$price) #price의 경우 $기호를 제거하는 작업을 한다.  
labtops$price = as.numeric(gsub("\\\\,", "",stringprice)) #,을 제거하고 as.numeric을 해야 에러가 안생긴다. 따라서 ,역시 삭제한다.  
labtops[,c(5)] <- sapply(labtops[,c(5)], as.numeric)  

#랭크도 평균을 계산할 것이므로 numeric으로한다.  
rank_char_ver <- as.character(labtops[,1]) #단, factor에서 numeric으로 바로 변환하면 이상한 결과가 나오므로 as.char을 한 번 거쳐서 바꾼다.  
labtops[,1] <- sapply(rank_char_ver, as.numeric)  


#회사들의 목록을 순서대로 나열한다.  
list_of_company <- unique(NOC)  
list_of_company<- list_of_company[order(list_of_company)]  


#각각의 통계량들을 계산한다.  
averRank <- vector("integer",0)  
averPrice <- vector("numeric",0)  
medianRank <- vector("integer",0)  
howManyProduct <- vector("integer",0)  








#항목들을 영어이름순으로 순서를 바꾼다.  
tbl <- table(labtops$NOC)  
tbl <- tbl[order(names(tbl))]

for(i in 1:length(list_of_company)){
  averRank[i] <- round(mean(labtops[labtops$NOC==list_of_company[i],]$rank))  
  averPrice[i] <- round(mean(labtops[labtops$NOC==list_of_company[i],]$price),2)  
  medianRank[i] <- median(labtops[labtops$NOC==list_of_company[i],]$rank)  
  howManyProduct[i] <- tbl[[i]]  
}

#통계처리한 데이터들을 가지고 따로 데이터프레임을 만든다.  
statistical_data <- as.data.frame(cbind(list_of_company,averPrice,averRank,howManyProduct),stringsAsFactors = F)  
statistical_data[,c(2,3,4)] <- sapply(statistical_data[ ,c(2:4)], as.numeric)




#통계처리한 데이터프레임을 가지고 그래프를 만든다.  
theme_set(  
  theme_bw() +  
    theme(legend.position = "right")  
)

b <- ggplot(statistical_data,aes(x=averRank, y=averPrice))

b + geom_point(aes(color = list_of_company, size = howManyProduct), alpha = 0.5) +   
  scale_fill_brewer(palette = "Greens")+  
  scale_size(range = c(4,10))

#각각  
#원의 크기: 제품의 수  
#원의 색깔: 회사구별  
#x축: 회사별 100위내 제품들의 평균순위  
#y축: 회사별 100위내 제품들의 평균가격  



remDr$close()
