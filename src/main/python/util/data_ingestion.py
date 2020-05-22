import urllib.request
import json
import datetime
from urllib.parse import urlencode, quote_plus
from urllib.request import urlopen
import pandas as pd
from bs4 import BeautifulSoup
import requests
import yaml

from util.executable import get_destination


def main():
    credentials_path = 'config/credentials.yaml'
    with open(get_destination(credentials_path)) as file:
        credentials = yaml.load(file, Loader=yaml.FullLoader)
    config_open_api = credentials['open_api']['emergency_data']

    config = {
        'end_point': config_open_api['end_point'],
        'service_key': config_open_api['service_key'],
        'connect_timeout': 5,
        'charset': 'utf8'
    }
    stage1 = '서울특별시'
    stage2 = '강남구'
    service_key = config['service_key']
    rest = '&STAGE1=' + stage1 + '&STAGE2=' + stage2
    url = config['end_point'] + "serviceKey=" + service_key + rest
    print(url)

    req = requests.get(url)
    soup = BeautifulSoup(req.content, 'html.parser')
    data = soup.find_all('item')


    """
        TODO: parsing data code (to use)
    """


    print(soup)

    # Data_injestion about json
    today = datetime.date.today()
    start_dt = today - datetime.timedelta(days=100)
    today = today.strftime('%Y%m%d')
    start_dt = start_dt.strftime('%Y%m%d')

    args = {
        'numberOfRows': 10,
        'pageNo': 1,
        'ServiceKey': "",
        'examinDe': today,
    }

    args_str = ""
    for k, v in args.items():
        args_str += '%s=%s' % (k, v)

    res = requests.get(
        'http://apis.data.go.kr/B552895/openapi/service/OrgPriceExaminService/getExaminPriceList?returnType=json%s' % args_str)
    data = res.json()
    items = data['response']['body']['items']
    df_items = pd.DataFrame(items)
    df_csv = df_items.to_csv('json.csv', encoding='utf-8-sig')
    print(items)

    # TODO : save df_csv , divide code as throwing args( json or xml or csv )





if __name__ == '__main__':
    main()