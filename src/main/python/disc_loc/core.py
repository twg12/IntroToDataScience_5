import pandas as pd
import requests
from bs4 import BeautifulSoup
from scipy.spatial import distance
from haversine import haversine
import geopandas
import folium




class Discrimination_Location:
    def __init__(self, dist):
        """
        :param x: x coordinate
        :param y: y coordinate
        """
        self.url_hpid = "http://apis.data.go.kr/B552657/ErmctInfoInqireService/getEmrrmRltmUsefulSckbdInfoInqire?\
        serviceKey=rdmH5XR5ycW9emHC9D56bNydZrvc6546Z0fxlqCdCPc4RpWZ99GMoGoRIKRabGJKz2WFcTwN9ekSTfCvzzhiYA%\
        3D%3D&pageNo=1&numOfRows=402"
        self.url_location = ""

        # TODO: store and load from s3
        self.df = pd.read_csv('C:\\Users\\park\\Desktop\\location.csv', encoding='euc-kr')

    def call_api_hpid(self):
        """
            get hpid list using html parser
        :return: hpid list
        """
        req = requests.get(self.url_hpid)
        html = req.text
        soup = BeautifulSoup(html, 'html.parser')

        # Get hpid list
        hpid = soup.find_all('hpid')
        hpid_list = list(map(lambda x: x.text, hpid))
        return hpid_list

    def call_api_location(self, hpid_list):
        """
            get location about hospital by hpid
            return : pd.DataFrame
            ( hpid, hname, x_coord, y_coord )
        """
        df = pd.DataFrame(columns=['hpid', 'hname', 'x_coord', 'y_coord'])

        for pid in hpid_list:
            url = 'http://apis.data.go.kr/B552657/ErmctInfoInqireService/getEgytBassInfoInqire?\
            serviceKey=rdmH5XR5ycW9emHC9D56bNydZrvc6546Z0fxlqCdCPc4RpWZ99GMoGoRIKRabGJKz2WFcTwN9ekSTfCvzzhiYA%3D%3D&\
            HPID=' + pid + '&pageNo=1&numOfRows=1&'
            req = requests.get(url)
            html = req.text
            soup = BeautifulSoup(html, 'html.parser')
            hpid = soup.find('hpid').text
            hname = soup.find('dutyname').text
            x_coord = soup.find('wgs84lat').text
            y_coord = soup.find('wgs84lon').text

            df = df.append({'hpid': hpid,
                            'hname': hname,
                            'x_coord': x_coord,
                            'y_coord': y_coord
                            }, ignore_index=True)

        # for calculating , declare dtype float
        df[['x_coord', 'y_coord']] = df[['x_coord', 'y_coord']].astype('float64')

        return df

    def df_to_csv(self, df:pd.DataFrame , path, file_name, encoding='euc-kr'):

        df.to_csv(path + '\\' + '{}.csv'.format(file_name) ,encoding=encoding)

    def load_target(self):

        # TODO: next day
        pass
def process(self):
        """
            1. Api call for hpid
            2. Api call for location using hpid
            3. load target.csv (Administrative area)
            4. calculate distance ( given number )
            5. visualization using folium
        """

        def func(x):
            print(haversine(x, (37.49794, 127.02758)))
            return haversine(x, (37.49794, 127.02758))

        self.df['new'] = 0
        loc = self.df.transform(lambda x: list(zip(self.df['x_coord'], self.df['y_coord'])))['new'][0:len(self.df['hpid'])]
        loc_list = loc.tolist()
        print(loc_list[0], loc_list[1])
        # 서울시청 126.97843, 37.56668
        # 강남역   127.02758, 37.49794

        dist_from_target = list(filter(lambda x: func(x) < 2, loc_list))

        print(dist_from_target)

    def load_target_xy(self):
        return pd.read_csv('C:\\Users\\park\\Desktop\\target_xy.csv')



def load_emergency(self):



        return pd.DataFrame