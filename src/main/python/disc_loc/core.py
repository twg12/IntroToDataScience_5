import pandas as pd
import requests
from bs4 import BeautifulSoup
from scipy.spatial import distance
from haversine import haversine
import geopandas
import folium
import boto3
import os
import webbrowser




class Discrimination_Location:
    def __init__(self, dist):
        """
        :param x: x coordinate
        :param y: y coordinate
        """
        self.url_hpid = "http://apis.data.go.kr/B552657/ErmctInfoInqireService/getEmrrmRltmUsefulSckbdInfoInqire?serviceKey=rdmH5XR5ycW9emHC9D56bNydZrvc6546Z0fxlqCdCPc4RpWZ99GMoGoRIKRabGJKz2WFcTwN9ekSTfCvzzhiYA%3D%3D&pageNo=1&numOfRows=402"
        self.url_location = ""

        # TODO: store and load from s3
        self.df = pd.read_csv('C:\\Users\\park\\Desktop\\location.csv', encoding='euc-kr')

        self.bucket = "introtodatascience5"
        self.key = "open_data/emergency_medical_service/origin/csv/"

        self.s3 = boto3.client('s3')
        # 's3' is a key word. create connection to S3 using default config and all buckets within S3
        print(self.url_hpid)

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
            url = 'http://apis.data.go.kr/B552657/ErmctInfoInqireService/getEgytBassInfoInqire?serviceKey=rdmH5XR5ycW9emHC9D56bNydZrvc6546Z0fxlqCdCPc4RpWZ99GMoGoRIKRabGJKz2WFcTwN9ekSTfCvzzhiYA%3D%3D&HPID=' + pid + '&pageNo=1&numOfRows=1&'
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

        df['xy'] = list(zip(df.x_coord, df.y_coord))

        return df

    def df_to_csv(self, df:pd.DataFrame , path, file_name, encoding='euc-kr'):

        df.to_csv(path + '\\' + '{}.csv'.format(file_name) ,encoding=encoding)

    def load_target(self, file_name):
        obj = self.s3.get_object(Bucket=self.bucket, Key=self.key+file_name)
        # get object and file (key) from bucket
        df = pd.read_csv(obj['Body'])  # 'Body' is a key word
        df['xy'] = list(zip(df.x_w84, df.y_w84))
        return df

    def calculate_distance(self, loop, target, distance):
        for loop_ in loop['xy']:
            if haversine(target, loop_) < distance:
                return target

    def map_circle(self, fol_map,  ws_list, color, radius):
        for i in ws_list:
            folium.Circle(
                    location=i,
                    color=color,
                    radius=radius,
            ).add_to(fol_map)

    def rendering_map(self, my_map, filepath):
        file_path = filepath+'\\map.html'
        my_map.save(file_path)
        webbrowser.open('file:\\' + file_path)

    def process(self):
        """
            1. Api call for hpid
            2. Api call for location using hpid <-> load from s3
            3. load target.csv (Administrative area)
            4. calculate distance ( given number )
            5. visualization using folium
        """
        hpid_list = self.call_api_hpid()
        loc_df = self.call_api_location(hpid_list=hpid_list)
        target_df = self.load_target('target_xy.csv')

        strong_location = list(map(lambda x: self.calculate_distance(loop=loc_df,
                                                                     target=x,
                                                                     distance=10), target_df['xy']))
        strong_loc = list(set(list(filter(None.__ne__, strong_location))))
        # print(len(strong_location), len(strong_loc)) result: 19956, 7830

        total_list = target_df['xy'].tolist()
        weak_list = list(set(total_list) - set(strong_loc))

        # (38, 127.5) = middle of korea
        fol_map = folium.Map(location=[38, 127.5], zoom_size=15)

        self.map_circle(fol_map=fol_map, ws_list=weak_list,
                        color='red', radius=300
                        )
        self.map_circle(fol_map=fol_map, ws_list=strong_loc,
                        color='blue', radius=300
                        )
        self.rendering_map(my_map=fol_map, filepath='C:\\Users\\park\\Desktop')






def load_emergency(self):



        return pd.DataFrame