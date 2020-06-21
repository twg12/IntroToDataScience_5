library(tidyverse)
library(sp)
library(rgdal)
library(geosphere)
library(shiny)
library(shinydashboard)
library(leaflet)
library(DT)
library(data.table)
library(ggplot2)

myfile = file.path("data")
SIG_1 = readOGR(myfile, "SIG_1")
hpdata_z <- read.csv("data/scaled_data.csv")

I <- function(x) {
    Input <- c(x) %>%
        recode("내과중환자실"="hv2", 
               "외과중환자실"="hv3", 
               "신경외과중환자실"="hv6",
               "응급실"="hvec",
               "입원실"="hvgc", 
               "수술실"="hvoc", 
               "소아"="hv10",
               "인큐베이터"="hv11", 
               "CT"="hvctayn",
               "MRI"="hvmriayn",
               "인공호흡기"="hvventiayn", 
               "뇌출혈수술"="mkioskty1",
               "뇌경색수술"="mkioskty2",
               "심근경색수술"="mkioskty3",
               "복부손상수술"="mkioskty4",
               "사지접합수술"="mkioskty5",
               "응급내시경"="mkioskty6",
               "응급투석"="mkioskty7",
               "조산산모"="mkioskty8" ,
               "신생아"="mkioskty10", 
               "중증화상"="mkioskty11")
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

bins = c(0, 4.476, 13.739, 32.531, 40.033, 84, Inf)
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
                fluidRow(selectInput("Variable", "   병원 점수를 알고 싶은 항목을 고르세요 ", list("내과중환자실", "외과중환자실", "신경외과중환자실",
                                                                                   "응급실","입원실","수술실", "소아",
                                                                                   "인큐베이터", 
                                                                                   "CT",
                                                                                   "MRI",
                                                                                   "인공호흡기", 
                                                                                   "뇌출혈수술",
                                                                                   "뇌경색수술",
                                                                                   "심근경색수술",
                                                                                   "복부손상수술",
                                                                                   "사지접합수술",
                                                                                   "응급내시경",
                                                                                   "응급투석",
                                                                                   "조산산모",
                                                                                   "신생아", 
                                                                                   "중증화상")),
                         box(title = "Table", dataTableOutput(outputId = "mytable")),
                         box(title = "Plot", plotOutput(outputId = "myplot")),
                         box(title = "File", downloadButton(outputId = "file", label = "Download the score file"))
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
    
    output$mytable = renderDataTable({datatable(LetsMakeScore_Score(input$Variable))})
    output$myplot = renderPlot({LetsMakeScore_Plot(input$Variable)})
    output$file = downloadHandler(filename = function(){
        paste(input$Variable, "-", Sys.Date(), ".csv", sep="")
    }, 
    content = function(go){write.csv(data.frame(LetsMakeScore_Score(input$Variable)), go)})
}

shinyApp(ui, server)

