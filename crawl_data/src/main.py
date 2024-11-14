import csv
from datetime import datetime
import pandas as pd

from selenium import webdriver
from selenium.webdriver.edge.options import Options

from crawl_data.src.crawl_data_product import crawl_data_product
from crawl_data.src.crawl_link_product import crawl_link


def crawl(config_crawl_link, config_crawl_product, limit_product):
    base_url = config_crawl_link['url']
    is_paging = config_crawl_link['is_paging']
    base_name = f"{config_crawl_link['location_file_save']}/{config_crawl_link['name']}"

    options = Options()
    options.add_argument('--headless')
    driver = webdriver.Edge(options)
    # driver.set_page_load_timeout(30)
    driver.get(base_url)
    driver.fullscreen_window()
    links = []
    if is_paging == 1:
        links = crawl_link(driver, config_crawl_link, limit_product)

    products = []
    total_success = 0
    total_fail = 0
    source = base_url
    start = datetime.now().__str__()
    for link in links:
        try:
            print("=" * 50, f"product: {len(products) + 1} / {len(links)}", "=" * 50)
            data = crawl_data_product(driver, link, config_crawl_product)
            if data['status'] == 'success':
                total_success += 1
            else:
                total_fail += 1
        except Exception:
            data = {'source': link, 'status': 'fail'}
            total_fail += 1

        products.append(data)

        columns = ['source', 'name', 'desks', 'colors', 'images', 'specifications', 'prices']
        (pd.DataFrame(data=[[product[column] for column in columns] for product in products if
                            product['status'] == 'success'],
                      columns=columns)
         .to_csv(f'{base_name}_{datetime.today().strftime("%Y-%m-%d")}.csv', index=False, encoding='utf-8'))

    driver.quit()
    return {
        "status": "CRAWL_SUCCESS",
        "date_update": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "total_crawl": len(products),
        "total_crawl_success": total_success,
        "total_crawl_fail": total_fail,
    }
