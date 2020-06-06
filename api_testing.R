mylocation = "C:/Users/Byeongjun Cho/Desktop/2020-1/데이터사이언스입문/data/open_api"
setwd(mylocation)

library(tidyverse)
library(httr)
library(XML)
library(xml2)
library(writexl)
library(tictoc)

# 응급의료기관 기본정보 조회 서비스
url = "http://openapi2.e-gen.or.kr/openapi/service/rest/ErmctInfoInqireService/"

## 응급실 실시간 가용병상정보 조회 1번 오퍼레이터

operator = "getEmrrmRltmUsefulSckbdInfoInqire"
Servicekey = "your_service_key"
pageNo = "1"
numOfRows = "99"

#  url_tmp = paste0(
#  url_1, paste0("?ServiceKey=", Servicekey), paste0("&STAGE1=", STAGE1), paste0("&STAGE2=", STAGE2), paste0("&pageNo=", pageNo),
#  paste0("&numOfRows=", numOfRows))

result_table_1 = tibble()
for (i in 1:10){
  queryParams = str_c("?serviceKey=", Servicekey, "&pageNo=", as.character(i), "&numOfRows=", "50")
  doc = xmlInternalTreeParse(str_c(url, operator, queryParams))
  rootNode = xmlRoot(doc)
  names = rootNode[[2]][['items']][['item']] %>%
    names()
  tmp_tbl = xmlToDataFrame(nodes = getNodeSet(rootNode, '//item')) %>%
    set_names(iconv(names, "UTF-8", "CP949") %>% unname()) %>%
    as_tibble()
  result_table_1 = result_table_1 %>% bind_rows(.,tmp_tbl)}

which(result_table_1$dutyName == "의료법인명지의료재단명지병원")
result_table_1[c(23, 391),] # 이름은 같지만 지역이 다른 명지병원이므로 인정
# 응급의료기관 지정 병원 갯수가 대략 402개 나옵니다

write_xlsx(result_table_1, "응급의료기관 기본정보 조회 서비스_1.xlsx")
write_excel_csv(result_table_1, "result_0527_12_16.csv")
# "result_mmdd_hh_mm.csv"

## 응급의료기관 조회서비스 3번 오퍼레이터 - 좌표값 찾기
pageNo = "1"
numOfRows = "99" # "&pageNo=", pageNo, "&numOfRows=", numOfRows
operator = "getEgytListInfoInqire"

result_table_3 = tibble()
for (i in 1:402){
  QN = result_table_1[i,1]
  queryParams = str_c("?serviceKey=", Servicekey, "&QN=", QN)
  doc = xmlInternalTreeParse(str_c(url, operator, queryParams))
  rootNode = xmlRoot(doc)
  tmp_tbl_2 = xmlToDataFrame(nodes = getNodeSet(rootNode, '//items//hpid')) %>% as_tibble(.name_repair = "unique")
  tmp_tbl_3 = xmlToDataFrame(nodes = getNodeSet(rootNode, '//items//dutyName')) %>% as_tibble(.name_repair = "unique")
  tmp_tbl_4 = xmlToDataFrame(nodes = getNodeSet(rootNode, '//items//wgs84Lon')) %>% as_tibble(.name_repair = "unique")
  tmp_tbl_5 = xmlToDataFrame(nodes = getNodeSet(rootNode, '//items//wgs84Lat')) %>% as_tibble(.name_repair = "unique")
  tmp_tbl_2 = tmp_tbl_2 %>% bind_cols(.,tmp_tbl_3) %>% bind_cols(.,tmp_tbl_4) %>% bind_cols(.,tmp_tbl_5)
  result_table_3 = result_table_3 %>% bind_rows(.,tmp_tbl_2)}

# which(result_table_3$text1 == "의료법인명지의료재단명지병원")
# result_table_3[c(21, 22, 389, 390),] # 이름은 같지만 지역이 다른 명지병원이므로 인정
# unique(result_table_3$text) # 고유 hpid값 371개
# result_table_3 = result_table_3 %>%
#  rename("hpid" = text, "dutyName" = text1, "wgs84Lon" = text2, "wgs84Lat" = text3)

write_xlsx(result_table_3, "응급의료기관 목록정보 조회 서비스_3.xlsx")

# tmp_join = subset(result_table_1, select = c(dutyName, hpid))
# full_join(result_table_3, tmp_join, by = c("text" = "hpid")) %>% count(duplicated(text3))

# (2) 중증질환자 수용가능 정보 오퍼레이터

operator = "getSrsillDissAceptncPosblInfoInqire"
result_table_2 = tibble()

for (i in 1:40){
  queryParams = str_c("?serviceKey=", Servicekey, "&pageNo=", as.character(i), "&numOfRows=", "14")
  doc = xmlInternalTreeParse(str_c(url, operator, queryParams))
  rootNode = xmlRoot(doc)
  names = rootNode[[2]][['items']][['item']] %>%
    names()
  tmp_tbl_2 = xmlToDataFrame(nodes = getNodeSet(rootNode, '//items')) %>%
    as_tibble(.name_repair = "unique")
  result_table_2 = result_table_2 %>% bind_rows(.,tmp_tbl_2)}

result_table_2.df = tibble()
for (i in 1:23){
  for (j in 1:14){
    result_table_2.df[j+14*(i-1),1] = str_extract(result_table_2[i,j], "[가-힣]+")
    result_table_2.df[j+14*(i-1),2] = str_extract(result_table_2[i,j], "[a-zA-Z][0-9]+")
    result_table_2.df[j+14*(i-1),3] = substr(str_extract(result_table_2[i,j], "[a-zA-Z]{12}"), 1, 1)
    result_table_2.df[j+14*(i-1),4] = substr(str_extract(result_table_2[i,j], "[a-zA-Z]{12}"), 2, 2)
    result_table_2.df[j+14*(i-1),5] = substr(str_extract(result_table_2[i,j], "[a-zA-Z]{12}"), 3, 3)
    result_table_2.df[j+14*(i-1),6] = substr(str_extract(result_table_2[i,j], "[a-zA-Z]{12}"), 4, 4)
    result_table_2.df[j+14*(i-1),7] = substr(str_extract(result_table_2[i,j], "[a-zA-Z]{12}"), 5, 5)
    result_table_2.df[j+14*(i-1),8] = substr(str_extract(result_table_2[i,j], "[a-zA-Z]{12}"), 6, 6)
    result_table_2.df[j+14*(i-1),9] = substr(str_extract(result_table_2[i,j], "[a-zA-Z]{12}"), 7, 7)
    result_table_2.df[j+14*(i-1),10] = substr(str_extract(result_table_2[i,j], "[a-zA-Z]{12}"), 8, 8)
    result_table_2.df[j+14*(i-1),11] = substr(str_extract(result_table_2[i,j], "[a-zA-Z]{12}"), 9, 9)
    result_table_2.df[j+14*(i-1),12] = substr(str_extract(result_table_2[i,j], "[a-zA-Z]{12}"), 10, 10)
    result_table_2.df[j+14*(i-1),13] = substr(str_extract(result_table_2[i,j], "[a-zA-Z]{12}"), 11, 11)
    result_table_2.df[j+14*(i-1),14] = substr(str_extract(result_table_2[i,j], "[a-zA-Z]{12}"), 12, 12)}}
result_table_2.df = result_table_2.df[1:313,]

write_xlsx(result_table_2.df, "중증질환자 수용가능 정보_2.xlsx")

## (5) 응급의료기관 기본정보 조회 오퍼레이션

operator = "getEgytBassInfoInqire"
result_table_5 = tibble()

for (i in 1:2000){
  tic()
  queryParams = str_c("?serviceKey=", Servicekey, "&pageNo=", as.character(i), "&numOfRows=", "50")
  doc = xmlInternalTreeParse(str_c(url, operator, queryParams))
  rootNode = xmlRoot(doc)
  tmp_tbl_2 = xmlToDataFrame(getNodeSet(rootNode, "//item")) %>% as_tibble()
  result_table_5 = result_table_5 %>% bind_rows(.,tmp_tbl_2)
  toc()}
write_xlsx(result_table_5, "응급의료기관 기본정보 조회_5_1.xlsx")

table(duplicated(result_table_5$dutyName))
# HPID = result_table_1[i,3]

## (8) 외상센터 기본정보 조회 오퍼레이션
operator = "getStrmBassInfoInqire"
result_table_8 = tibble()
for (i in 1:10){
  queryParams = str_c("?serviceKey=", Servicekey, "&pageNo=", as.character(i), "&numOfRows=", "50")
  doc = xmlInternalTreeParse(str_c(url, operator, queryParams))
  rootNode = xmlRoot(doc)
  tmp_tbl_3 = xmlToDataFrame(nodes = getNodeSet(rootNode, '//item')) %>% as_tibble()
  result_table_8 = result_table_8 %>% bind_rows(.,tmp_tbl_3)}

write_xlsx(result_table_8, "외상센터 기본정보 조회_8.xlsx")

## 미활용 api 크롤링 코드

# 건강보험심사평가원 병원정보서비스

url = "http://apis.data.go.kr/B551182/hospInfoService/"
operator = "getHospBasisList" # 기본정보 오퍼레이터
queryParams = str_c("?serviceKey=", Servicekey, "&numOfRows=","99","&zipCd=", "2030")
doc = xmlInternalTreeParse(str_c(url, operator, queryParams))
rootNode = xmlRoot(doc)

#   tmp_tbl_2 = xmlToDataFrame(nodes = getNodeSet(rootNode, '//item')) %>%
# set_names(iconv(names, "UTF-8", "CP949") %>% unname()) %>%
#   as_tibble()
# result_table_2 = result_table_2 %>% bind_rows(.,tmp_tbl_2)}

names = rootNode[[2]][['items']][['item']] %>%
  names()
tmp_tbl3 = xmlToDataFrame(nodes = getNodeSet(rootNode, '//item')) %>%
  as_tibble()

tmp_tbl3$ykiho # 요양코드, 상세정보 서비스 검색에 필요

# 건강보험심사평가원 의료기관별 상세정보서비스

url = "http://apis.data.go.kr/B551182/medicInsttDetailInfoService/"
operator = "getDetailInfo" # 세부정보 오퍼레이터
queryParams = str_c("?serviceKey=", Servicekey, "&ykiho=", ykiho)
doc = xmlInternalTreeParse(str_c(url, operator, queryParams))
rootNode = xmlRoot(doc)

names = rootNode[[2]][['items']][['item']] %>%
  names()
tmp_tbl4 = xmlToDataFrame(nodes = getNodeSet(rootNode, '//item')) %>%
  as_tibble()

###----####

# result_table_1(402개)과 result_table_3(400개)으로 파이썬 워크플로우 따라가기 (notion 내용 참고)

library(sp)
library(rgdal)

TL = readOGR(mylocation, "TL_SCCO_LI") # 첫 인자에 파일 위치, 두번째 인자에 파일명
plot(TL, axes = T) # 무작정 시각화 (시간이 오래 걸려서 넘어가도 됨) (남한 지도 나옴)

# Option1 불러온 공간 데이터 내에서 좌표계 방식 변환  (UTM-K -> WGS84)
# Option2 하단 서술

# from.crs = TL@proj4string
from_crs = CRS("+proj=tmerc +lat_0=38 +lon_0=127.5 +k=0.9996 +x_0=1000000 +y_0=2000000 +ellps=GRS80 +units=m +no_defs")
to_crs = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

proj4string(TL) = from_crs
TL_1 = spTransform(TL, to_crs)

tmp_1 = TL_1@data

for (i in 1:nrow(tmp_1)){
  tmp_1$x_coord[i] = parse_number(as.character(TL_1@polygons[[i]]@labpt)[1])
  tmp_1$y_coord[i] = parse_number(as.character(TL_1@polygons[[i]]@labpt)[2])
}

# Haversine 공식으로 거리 계산

library(geosphere)

dist = list()
for (i in 1:nrow(tmp_1)){
dist[[i]] = c(tmp_1$x_coord[i], tmp_1$y_coord[i])
}

medi = list()
for (i in 1:nrow(result_table_3)){
  medi[[i]] = c(parse_number(result_table_3$text2[i]), parse_number(result_table_3$text3[i]))
}

# 거리 계산하여 10km 이내에 도달 가능한 응급의료기관 수 계산

tmp_1$num = 0
for (i in 1:length(dist)){
  for (j in 1:length(medi)){
  ifelse(distHaversine(dist[[i]], medi[[j]])<10000, tmp_1$num[i] <- tmp_1$num[i]+1, next)
  }
}

write.csv(tmp_1, "Haversine_list.csv")

# 간단한 인터랙티브 시각화
library(leaflet)

TL_1 = sp::merge(TL_1, tmp_1)
pal2 = colorNumeric("viridis", TL_1@data$num, reverse=TRUE)

leaflet(TL_1) %>%
  setView(lng=127.7669,lat=35.90776, zoom=7) %>%
  addProviderTiles('CartoDB.Positron') %>%
  addPolygons(color='#444444', weight=0.5, opacity = 1.0, fillOpacity = 0.5, fillColor=~pal2(num))

# Option2 polygon 좌표의 labpt 변수(평면상의 좌표 라벨)만 추출해서 좌표 변환
# raw 데이터 보존과 파일 용량을 고려해 이 방식으로 해보려고 했는데 에러 처리가 어렵네요..

TL_tbl = TL %>% as_tibble()
tmp = TL@data

for (i in 1:nrow(TL_tbl)){
  TL_tbl$x_coord[i] = as.character(TL@polygons[[i]]@labpt)[1]
  TL_tbl$y_coord[i] = as.character(TL@polygons[[i]]@labpt)[2]
}

for (i in 1:nrow(tmp)){
  tmp$x_coord[i] = parse_number(as.character(TL@polygons[[i]]@labpt)[1])
  tmp$y_coord[i] = parse_number(as.character(TL@polygons[[i]]@labpt)[2])
}

# from.crs = TL@proj4string
from.crs = "+proj=tmerc +lat_0=38 +lon_0=127.5 +k=0.9996 +x_0=1000000 +y_0=2000000 +ellps=GRS80 +units=m +no_defs"
to.crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

convertCoordSystem = function(long, lat, from.crs, to.crs){
  xy = data.frame(long=long, lat=lat)
  coordinates(xy) = ~long+lat
  
  from.crs = CRS(from.crs)
  from.coordinates = SpatialPoints(xy, proj4string=from.crs)
  
  to.crs = CRS(to.crs)
  changed = as.data.frame(SpatialPoints(spTransform(from.coordinates, to.crs)))
  names(changed) = c("long", "lat")
  
  return(changed)
}

TL_tbl_1 = bind_cols(TL_tbl,
convertCoordSystem(parse_number(TL_tbl$x_coord), parse_number(TL_tbl$y_coord), 
                   from.crs, to.crs))

# coordinates(xy) = ~tmp$x_coord+tmp$y_coord 여기서 문제 발생
