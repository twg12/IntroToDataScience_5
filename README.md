# 골든타임 (Golden Time)

# 프로젝트 소개
## 주제
**접근성과 의료 시설 인프라 분석을 통한 종합적 응급 의료 취약지 선정**

## 기존 응급 의료 취약지 선정의 문제점

- ["보건복지부는 최근 행정예고를 통해 ‘**지역응급의료센터로 30분내 도달이 불가능**하거나, **권역응급의료센터로 1시간 이내 도달이 불가능**한 인구가 지역 내 30% 이상인 지역’을 응급의료취약지로 지정하도록 했다."](http://www.docdocdoc.co.kr/news/articleView.html?idxno=1038322)

보건 복지부에서 시행한 응급 의료 취약지 지정은 아래와 같은 이유로 현 응급 의료 실태와 일치하지 않는다.

1. **응급의료기관의 인프라(시설)이 고려되지 않는다.**
"동맥박리, 사지절단 환자를 수술할 수 있는 의사는 국내 10여명뿐인데 해외출장 중이라면 다른 병원 의사를 물색해야 하고, 독극물 중독 환자에게는 해독제를 줘야 하는데, 해독제가 있는 병원도 전국에 20여곳뿐"
    - 해당 병원이 얼마나 많은 환자를 수용할 수 있으며, 어떤 응급 처치를 수행할 수 있는지에 대한 분석이 제외되어있다.
    - 이는, 해당 자원이 부족한 응급 시설에 대한 지원 부족으로 이어질 수 있으며, 아래와 같은 문제점을 유발한다.  
  
2. **다른 병원 재이송**
    - 병원이 응급 진료를 거부하는 주요 이유로는,  1) 전문의 부재(23.2%), 2) 진료과 없음(13.4%) 두가지가 1, 2위를 차지한다.
    - 추가적으로, 병상부족이 8.6%를 차지한다.
    - 한 해 약 1050만명의 환자가 응급실을 찾지만, 다른 병원으로 재이송 되는 사례는 약 3만 3000여건이다. 이 중 전문의 부재, 진료과 없음의 이유로 재이송 되는 비율은 36.6%를 차지한다. 
    - '병상 부족'이라는 사유를 포함하면 약 1만 5000여건의 응급 상황이 의료 시설 인프라 부족을 이유로 골든 타임을 놓치게 된다.

## 프로젝트 목차

위와 같은 현재 응급 의료 취약지 선정의 한계점으로부터, 우리는 골든타임의 측정은 단순한 인근 의료시설의 접근 시간에 대한 지수가 되어서는 안되며, 적절한 응급 인프라를 통해 정확한 진료를 받을 수 있을 때까지의 시간으로 측정되어야 한다는 점에 동의했다.
  
프로젝트 설명은 아래와 같은 순서로 진행된다.
  
  1. **접근성 분석**  
특정 좌표를 중심으로 제한된 반경 내에 존재하는 병원의 수를 측정한다.  

  2. **응급 의료 시설의 인프라 점수 분석**  
병원의 재이송 비율을 병상수와 같은 응급 환자 수용 시설과 관련된 요인에서부터, 심혈관 전문의 등, 해당 병원의 특정 질환을 갖는 응급 환자 수용 가능 여부에 대한 변수를 설정하고 이에 대한 점수를 통계적 기법을 통해 제시한다.  

  3. **최종 시각화**  
앞서 분석한 접근성, 인프라 점수를 종합적으로 분석해 응급의료 취약지를 시각화한다.  
이를 통해, 응급의료기관 입지 선정의 최소비용 최대효율을 낼 수 있는 장소를 예측한다.

**프로젝트 블로그 페이지**  

아래 링크를 통해 1) 회의록, 2) 프로젝트 전체를 확인할 수 있다.  

- [Project GoldenTime](https://ds2020-goldentime.netlify.app/)

- [Blog GitHub Site](https://github.com/YoonHoJeong/ds_2020_goldentime_blog)
