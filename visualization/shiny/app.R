library(tidyverse)
library(sp)
library(rgdal)
library(geosphere)
library(readxl)
library(shiny)
library(shinydashboard)
library(leaflet)
library(DT)
library(data.table)
library(ggplot2)

myfile = file.path("data")
SIG_1 = readOGR(myfile, "SIG_1")
hpdata_z <- read.csv("data/scaled_data.csv")

pop = read_xlsx("data/population_1.xlsx")
pop = pop %>%
    mutate(행정기관코드 = str_sub(행정기관코드, 1, 5)) %>%
    rename(SIG_CD = '행정기관코드', name = '행정기관', howmany = '총인구수') %>%
    select(SIG_CD, name, howmany)
pop$howmany = gsub(",","", pop$howmany)
pop = pop %>% 
    mutate(howmany = as.numeric(howmany), SIG_CD = as.factor(SIG_CD))
tmp_1 = SIG_1@data %>% as_tibble()
tmp_2 = right_join(tmp_1, pop, by = "SIG_CD") %>% as.data.frame()
for (i in 1:nrow(tmp_2)){
tmp_2$weak[i] = ifelse(tmp_2$score_num[i] < 13 && tmp_2$howmany[i] > 0.25*tmp_2$howmany[tmp_2$name == strsplit(tmp_2$name, " ")[[i]][[1]]], 1, 0)
}
for (i in 1: nrow(tmp_2)){
tmp_2$score_num[i] = ifelse(tmp_2$weak[i] == 1, -10, tmp_2$score_num[i])}

I <- function(x) {
    Input <- c(x)
    return(Input)
}

LetsMakeScore_Plot <- function(x) {
    hpdata_z_tmp <- hpdata_z
    sc <- hpdata_z_tmp %>%
        select(I(x))%>%
        prcomp()
    sc_2 <- predict(sc)[,1]
    ifelse(sum(sc[[2]][,1]) > 0, sc <- sc_2, sc <- -sc_2)  
    sc <- 100+20*scale(sc)
    sc <- ifelse(sc<0, 0, sc)
    hp_score <- hpdata_z_tmp %>%
        select(dutyName.x, hpid) %>%
        mutate(score= sc)
    hp_score %>%
        ggplot(aes(x=score)) +
        geom_histogram(fill='sky blue', binwidth = 3)+
        xlab("점수 분포")+
        ylab("병원 수")+
        theme_bw()+
        theme(axis.title.x = element_text(size = 15))+
        theme(axis.title.y = element_text(size = 15))
}

LetsMakeScore_Score <- function(x) {
    sc <- hpdata_z %>%
        select(I(x))%>%
        prcomp()
    sc_2 <- predict(sc)[,1]
    ifelse(sum(sc[[2]][,1]) > 0, sc <- sc_2, sc <- -sc_2)  
    sc <- 100+20*scale(sc)
    sc <- ifelse(sc<0, 0, sc)
    hp_score <- hpdata_z %>%
        select(dutyName.x, hpid) %>%
        mutate(score= sc)
    hp_score %>%
        select(dutyName.x, hpid, score)
}

bins = c(-Inf,-10, 0, 4.476, 13.739, 32.531, 40.033, 84, Inf)
pal = colorBin("YlGnBu", domain = SIG_1@data$score_num, bins = bins)

labels <- sprintf(
    "<strong>%s</strong><br/>%g points",
    SIG_1@data$SIG_ENG_NM, SIG_1@data$score_num
) %>% lapply(htmltools::HTML)
# 'CartoDB.Positron'

header = dashboardHeader(title = "Golden-Time")

sidebar = dashboardSidebar(
    sidebarMenu(
        menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
        menuItem("Widgets", tabName = "tables", icon = icon("th"))))

body = dashboardBody(
    tabItems(
        tabItem(tabName = "dashboard", h2("전국 시군구 단위 응급의료기관 접근성 점수화"),
                fluidRow( 
                    leafletOutput(outputId = "mymap", height = "800px", width = "125%"))),
        tabItem(tabName = "tables", h2("Widgets"),
                fluidRow(selectInput("Variable", "   병원 점수를 알고 싶은 항목을 고르세요 ", colnames(hpdata_z)[-c(1,2)]),
                         box(title = "Table", dataTableOutput(outputId = "mytable")),
                         box(title = "Plot", plotOutput(outputId = "myplot")),
                         box(title = "File", downloadButton(outputId = "file", label = "Download the score file"), width = 4),
                         box(title = "Legend", tableOutput(outputId = "mylegend"))
                ))))

ui <- dashboardPage(header, sidebar, body)

server <- function(input, output) {
    output$menu <- renderMenu({
        menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
        menuItem("Widgets", tabName = "tables", icon = icon("th"))
    })
    pal2 = colorNumeric("viridis", SIG_1@data$score_num, reverse=TRUE)
    
    output$mymap = renderLeaflet({
        leaflet(SIG_1) %>%
            setView(lng=127.7669,lat=35.90776, zoom=7.5) %>%
            addProviderTiles("MapBox", options = providerTileOptions(
                id = "mapbox.light",
                accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN'))) %>%
            addPolygons(color='#444444', 
                        weight=2, opacity = 1.0, fillOpacity = 0.5, 
                        fillColor=~pal(score_num),
                        label = labels,
                        labelOptions = labelOptions(
                            style = list("font-weight" = "normal", padding = "3px 8px"),
                            textsize = "15px",
                            direction = "auto")
            ) %>%
            addLegend(pal = pal, values = ~score_num, opacity = 0.7, title = "Emergency Score",
                      position = "bottomright")})
    
    output$mylegend = renderTable({tribble(
        ~Item, ~Name, ~Item, ~Name,
        "hv2", "내과중환자실", "mkioskty1", "뇌출혈수술",
        "hv3", "외과중환자실", "mkioskty2", "뇌경색수술",
        "hv6", "신경외과중환자실", "mkioskty3", "심근경색수술",
        "hvec", "응급실", "mkioskty4", "복부손상수술",
        "hvgc", "입원실", "mkioskty5", "사지접합수술",
        "hvoc", "수술실", "mkioskty6", "응급내시경",
        "hv10", "소아", "mkioskty7", "응급투석",
        "hv11", "인큐베이터", "mkioskty8", "조산산모",
        "hvctayn", "CT", "mkioskty10", "신생아",
        "hvmriayn", "MRI", "mkioskty11", "중증화상",
        "hvventiayn", "인공호흡기","","")})
    output$mytable = renderDataTable({datatable(LetsMakeScore_Score(input$Variable))})
    output$myplot = renderPlot({LetsMakeScore_Plot(input$Variable)})
    output$file = downloadHandler(filename = function(){
        paste(input$Variable, "-", Sys.Date(), ".csv", sep="")
    }, 
    content = function(go){write.csv(data.frame(LetsMakeScore_Score(input$Variable)), go)})
}

shinyApp(ui, server)

