import urllib.request
import json
import pandas as pd
import requests
from bs4 import BeautifulSoup

from pandas.io.json import json_normalize



def main():


    url = 'http://apis.data.go.kr/B552657/ErmctInfoInqireService/getEmrrmRltmUsefulSckbdInfoInqire?serviceKey=rdmH5XR5ycW9emHC9D56bNydZrvc6546Z0fxlqCdCPc4RpWZ99GMoGoRIKRabGJKz2WFcTwN9ekSTfCvzzhiYA%3D%3D&pageNo=1&numOfRows=402'
    req = requests.get(url)
    html = req.text
    soup = BeautifulSoup(html, 'html.parser')

    # Get hpid list
    hpid = soup.find_all('hpid')
    hpid_list = list(map(lambda x: x.text, hpid))
    print(hpid_list)
    # 'A2200011'

    df = pd.DataFrame(columns=['hpid', 'hname', 'x_coord', 'y_coord'])

    for pid in hpid_list:
        url2 = 'http://apis.data.go.kr/B552657/ErmctInfoInqireService/getEgytBassInfoInqire?serviceKey=rdmH5XR5ycW9emHC9D56bNydZrvc6546Z0fxlqCdCPc4RpWZ99GMoGoRIKRabGJKz2WFcTwN9ekSTfCvzzhiYA%3D%3D&HPID=' + pid + '&pageNo=1&numOfRows=1&'
        req2 = requests.get(url2)
        html2 = req2.text
        soup2 = BeautifulSoup(html2, 'html.parser')
        hpid2 = soup2.find('hpid').text
        hname = soup2.find('dutyname').text
        x_coord = soup2.find('wgs84lat').text
        y_coord = soup2.find('wgs84lon').text

        df = df.append({'hpid': hpid2,
                        'hname': hname,
                        'x_coord': x_coord,
                        'y_coord': y_coord
                        }, ignore_index=True)

    df[['x_coord', 'y_coord']] = df[['x_coord', 'y_coord']].astype('float64')

    df.to_csv('C:\\Users\\park\\Desktop\\location.csv', encoding='euc-kr')
    print(df)


    #    return hpid2, hname
    # func('A2200011')


if __name__ == '__main__':
    main()