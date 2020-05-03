import urllib.request
import json

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

    #
    # response = urllib.request.urlopen(url)
    #
    # json_str = response.read().decode("utf-8")
    #
    # json_object = json.loads(json_str)
    # print(json_object)


    #
    # url = 'http://openapi2.e-gen.or.kr/openapi/service/rest/ErmctInfoInqireService/getEmrrmRltmUsefulSckbdInfoInqire'
    # queryParams = '?' + urlencode(
    #     {quote_plus('ServiceKey'): '서비스키', quote_plus('STAGE1'): '서울특별시', quote_plus('STAGE2'): '강남구',
    #      quote_plus('pageNo'): '1', quote_plus('numOfRows'): '10'})
    #
    # request = urllib.request(url + queryParams)
    # request.get_method = lambda: 'GET'
    # response_body = urlopen(request).read()
    # print(response_body)
    #


if __name__ == '__main__':
    main()