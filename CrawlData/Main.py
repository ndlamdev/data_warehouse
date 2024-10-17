from datetime import datetime

from selenium import webdriver
from selenium.webdriver.edge.options import Options
from dotenv import load_dotenv
import os
import json

from CrawlData.CrawlDataProduct import crawl_data_product
from CrawlData.DrawlLinkProduct import crawl_link

load_dotenv()

base_url = os.getenv("URL")
is_paging = os.getenv('IS_PAGING')
css_selector_view_more = os.getenv('VIEW_MORE')
css_selector_product_item = os.getenv('PRODUCT_ITEM')


def run():
    options = Options()
    options.add_argument('--headless')
    driver = webdriver.Edge(options)
    driver.get(base_url)
    links = []
    if is_paging == 'True':
        links = crawl_link(driver)

    data_file = {'source': base_url, 'start': datetime.now().__str__()}
    products = []
    total_success = 0
    total_fail = 0
    for link in links:
        try:
            data = crawl_data_product(driver, link)
            if data['status'] == 'success':
                total_success += 1
            else:
                total_fail += 1
        except Exception:
            data = {'source': link, 'status': 'fail'}
            total_fail += 1
        print(data)
        products.append(data)

    data_file['end'] = datetime.now().__str__()
    data_file['total_product'] = len(products)
    data_file['total_success'] = total_success
    data_file['total_fail'] = total_fail
    data_file['datas'] = products
    with open('product.json', 'w', encoding='utf-8') as file:
        json.dump(data_file, file, ensure_ascii=False)


run()
