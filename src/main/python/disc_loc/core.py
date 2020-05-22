import pandas as pd
import numbers
import math
from scipy.spatial import distance
from haversine import haversine
import geopandas
import folium

class Discrimination_Location:
    def __init__(self, x: float = 37, y: float = 128):
        """
        :param x: x coordinate
        :param y: y coordinate
        """
        self.x_coord = x
        self.y_coord = y
        self.df = pd.read_csv('C:\\Users\\park\\Desktop\\location.csv', encoding='euc-kr')


    def process(self):
        print(self.df)
        print(self.df.dtypes)


        def func(x):
            print(haversine(x, (37.49794, 127.02758)))
            return haversine(x, (37.49794, 127.02758))

        self.df['new'] = 0
        loc = self.df.transform(lambda x: list(zip(self.df['x_coord'], self.df['y_coord'])))['new'][0:len(self.df['hpid'])]
        loc_list = loc.tolist()
        print(loc_list[0], loc_list[1])
        #126.97843, 37.56668, 127.02758, 37.49794
        # 서울시청 126.97843, 37.56668
        # 강남역   127.02758, 37.49794

        dist_from_target = list(filter(lambda x: func(x) < 2, loc_list))

        print(dist_from_target)

    def load_target_xy(self):
        return pd.read_csv('C:\\Users\\park\\Desktop\\target_xy.csv')



def load_emergency(self):



        return pd.DataFrame