from datetime import datetime
from typing import TextIO
from xmlrpc.client import DateTime

from selenium import webdriver
from selenium.webdriver.edge.options import Options
import json

from crawl_data.config.env import init_env
from crawl_data.crawl.crawl_data_product import crawl_data_product
from crawl_data.crawl.crawl_link_product import crawl_link

limit_product = 50


def crawl(env=""):
    init_env(env)
    from crawl_data.config.env import base_url, is_paging

    options = Options()
    options.add_argument('--headless')
    driver = webdriver.Edge(options)
    driver.set_page_load_timeout(30)
    driver.get(base_url)
    driver.fullscreen_window()
    links = []
    if is_paging == 'True':
        links = crawl_link(driver, limit_product)

    products = []
    total_success = 0
    total_fail = 0
    data_file = {'source': base_url, 'start': datetime.now().__str__()}
    for link in links:
        try:
            print("=" * 50, f"product: {len(products) + 1} / {len(links)}", "=" * 50)
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
        with open(f'data/{env}_{datetime.today().strftime('%Y-%m-%d')}.json', 'w', encoding='utf-8') as file:
            json.dump(data_file, file, ensure_ascii=False)
            file.close()

    driver.quit()
