mylocation = "C:/Users/Byeongjun Cho/Desktop/2020-1/데이터사이언스입문/data/open_api"
setwd(mylocation)
library(tidyverse)
library(httr)
library(XML)
library(xml2)

# 응급의료기관 기본정보 조회 서비스
url = "http://openapi2.e-gen.or.kr/openapi/service/rest/ErmctInfoInqireService/"  
operator = "getEmrrmRltmUsefulSckbdInfoInqire" # 응급실 실시간 가용병상정보 조회 오퍼레이터
Servicekey = "your_service_key"
STAGE1 = ""
STAGE2 = ""
pageNo = "1"
numOfRows = "99"

# url_tmp = paste0(
#  url_1, paste0("?ServiceKey=", Servicekey), paste0("&STAGE1=", STAGE1), paste0("&STAGE2=", STAGE2), paste0("&pageNo=", pageNo),
#  paste0("&numOfRows=", numOfRows))

region = read.csv("시군구명 활용_ 건강보험심사평가원_시군구별 요양기관 현황 2018.csv") %>% as_tibble()
region = region %>% rename(code1 = "시도.구분", code2 = "시군구.구분")
region.1 = region %>% mutate(code1.1 = 
                               case_when(code1 == "서울" ~ "서울특별시",
                                         code1 == "강원" ~ "강원도",
                                         code1 == "경기" ~ "경기도",
                                         code1 == "경남" ~ "경상남도",
                                         code1 == "경북" ~ "경상북도",
                                         code1 == "광주" ~ "광주광역시",
                                         code1 == "대구" ~ "대구광역시",
                                         code1 == "대전" ~ "대전광역시",
                                         code1 == "부산" ~ "부산광역시",
                                         code1 == "세종" ~ "세종특별자치시",
                                         code1 == "충남" ~ "충청남도",
                                         code1 == "전북" ~ "전라북도",
                                         code1 == "전남" ~ "전라남도",
                                         code1 == "경북" ~ "경상북도",
                                         code1 == "경남" ~ "경상남도",
                                         code1 == "제주" ~ "제주특별자치도",
                                         code1 == "충북" ~ "충청북도",
                                         code1 == "인천" ~ "인천광역시",
                                         code1 == "울산" ~ "울산광역시"))
region.2 = tibble()
for (i in 1:228){
  region.2[i,1] = unique(region.1$code1.1[region.1$code2 == unique(region.1$code2)[i]])[1]
  region.2[i,2] = unique(region.1$code2)[i]
}
region.2 = region.2 %>% mutate(...2 = as.character(...2))

result_table = tibble()
for (i in 1:91){
  STAGE1 = region.2[i,1]
  STAGE2 = region.2[i,2]
  queryParams = str_c("?serviceKey=", Servicekey, "&STAGE1=", STAGE1, "&STAGE2=", STAGE2, "&pageNo=", pageNo, "&numOfRows=", numOfRows)
  doc = xmlInternalTreeParse(str_c(url, operator, queryParams))
  rootNode = xmlRoot(doc)

  names = rootNode[[2]][['items']][['item']] %>%
    names()
  tmp_tbl = xmlToDataFrame(nodes = getNodeSet(rootNode, '//item')) %>%
    set_names(iconv(names, "UTF-8", "CP949") %>% unname()) %>%
    as_tibble()
  result_table = result_table %>% bind_rows(.,tmp_tbl)}
# 92번은 오류가 나서 1:91, 93:228 나눠서 돌리시는 게 제일 빠르더라구요
# 응급의료기관 지정 병원 갯수가 대략 340개 정도 나옵니다
write_excel_csv(result_table, "result_mmdd_hh_mm.csv")

url = "http://apis.data.go.kr/B552657/ErmctInfoInqireService/"
operator = "getSrsillDissAceptncPosblInfoInqire" # 중증질환자 수용가능 정보 오퍼레이터
result_table_2 = tibble()
SM_TYPE = "1"
for (i in 1:91){
  STAGE1 = region.2[i,1]
  STAGE2 = region.2[i,2]
  queryParams = str_c("?serviceKey=", Servicekey, "&STAGE1=", STAGE1, "&STAGE2=", STAGE2)
  doc = xmlInternalTreeParse(str_c(url, operator, queryParams))
  rootNode = xmlRoot(doc)
  
  names = rootNode[[2]][['items']][['item']] %>%
    names()
  tmp_tbl_2 = xmlToDataFrame(nodes = getNodeSet(rootNode, '//item')) %>%
    as_tibble()
  result_table_2 = result_table_2 %>% bind_rows(.,tmp_tbl_2)}

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