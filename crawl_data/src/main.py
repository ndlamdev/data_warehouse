from datetime import datetime

import pandas as pd
from selenium import webdriver
from selenium.webdriver.edge.options import Options

from crawl_data.src.crawl_data_product import crawl_data_product
from crawl_data.src.crawl_link_product import crawl_link
from database import controller_connector
from send_mail import send_mail
from util import read_data_config, read_data_log


def crawl(config_crawl_link,
          config_crawl_product,
          limit_product,
          name,
          location_file_save):
    date = datetime.now()
    base_url = config_crawl_link['url']
    base_name = f"{location_file_save}/{name}"
    columns = ['source', 'name', 'desks', 'colors', 'images', 'specifications', 'prices']

    options = Options()
    options.add_argument('--headless')
    driver = webdriver.Edge(options)
    # driver.set_page_load_timeout(30)
    driver.get(base_url)
    driver.fullscreen_window()
    links = crawl_link(driver, config_crawl_link, limit_product)

    products = []
    total_success = 0
    total_fail = 0
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

        (pd.DataFrame(data=[[product[column] for column in columns] for product in products if
                            product['status'] == 'success'],
                      columns=columns)
         .to_csv(f'{base_name}_{date.strftime("%Y-%m-%d")}.csv', index=False, encoding='utf-8'))

    driver.quit()
    return {
        "status": "CRAWL_SUCCESS",
        "date_update": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "total_crawl": len(products),
        "total_crawl_success": total_success,
        "total_crawl_fail": total_fail,
    }


def init_log(file_config_id, name, date):
    if not isinstance(date, datetime):
        raise Exception("date must be a datetime from datetime")

    controller_connector.create(table="file_logs",
                                data={
                                    'file_config_id': int(file_config_id),
                                    'file_name': f'{name}_{date.strftime('%Y-%m-%d')}',
                                    'status': 'CRAWLING',
                                    'date': date.strftime('%Y-%m-%d'),
                                    'date_update': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                                    'total_crawl': 0,
                                    'total_crawl_success': 0,
                                    'total_crawl_fail': 0
                                })


def get_control_crawl_data_product_css_selectors_by_id(crawl_data_product_css_selectors_id):
    columns = [
        'button_close_pop_up',
        'title',
        'product_container',
        'specifications_container',
        'desks',
        'colors',
        'desk_links',
        'color_links',
        'status',
        'price',
        'discount',
        'images',
        'show_more_specifications',
        'group_specifications',
        'name_group_specifications',
        'row_specifications',
        'title_specifications',
        'value_specifications',
    ]

    data = controller_connector.read(table="crawl_data_product_css_selectors",
                                     columns=", ".join(columns),
                                     condition=f"id = {crawl_data_product_css_selectors_id}")

    obj = {}
    for column in columns:
        obj[column] = data[0][columns.index(column)]
    return obj


def get_control_crawl_link_css_selectors_by_id(control_crawl_link_css_selectors_id):
    columns = [
        'url',
        'is_paging',
        'view_more',
        'next_page',
        'button_close_pop_up',
        'product_item',
    ]

    data = controller_connector.read(table="crawl_link_css_selectors",
                                     columns=", ".join(columns),
                                     condition=f"id = {control_crawl_link_css_selectors_id}")

    obj = {}
    for column in columns:
        obj[column] = data[0][columns.index(column)]
    return obj


def crawl_data(ids=None, date=datetime.now()):
    configs = read_data_config(ids)
    for row in range(configs.shape[0]):
        config = configs.iloc[row]
        config_id = config['id']
        log = read_data_log(config_ids=[config_id], date=date)
        if not log.empty and log['status'].values[0] != "CRAWL_FAIL":
            print(f"File config id {config_id} is ${log['status']}!")
            continue

        name = config['name']
        crawl_data_product_css_selectors_id = configs.iloc[row]['crawl_data_product_css_selectors_id']
        crawl_link_css_selectors_id = configs.iloc[row]['crawl_link_css_selectors_id']
        limit_product = config['limit_item']
        location_file_save = config['location_file_save']

        if log.empty:
            init_log(config_id, name, date)
            print(f"File config id {config_id} init log success!")
        else:
            print(f"File config id {config_id} is {log['status'].values[0]}!")

        config_crawl_data = get_control_crawl_data_product_css_selectors_by_id(crawl_data_product_css_selectors_id)
        config_crawl_link = get_control_crawl_link_css_selectors_by_id(crawl_link_css_selectors_id)

        try:
            data_crawl = crawl(config_id, config_crawl_link, config_crawl_data, limit_product, name, location_file_save)
        except Exception as e:
            send_mail(subject="Crawl link fail", content=e.__str__())
            controller_connector.update(table="file_logs",
                                        data={
                                            "status": "CRAWL_FAIL",
                                            "date_update": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                                        },
                                        condition=f"date = DATE('{date.strftime('%Y-%m-%d')}') and file_config_id = {config_id}"
                                        )
            continue

        send_mail(subject="Crawl data success", content=f"Craw data for file config id {config_id} success!")
        controller_connector.update(table="file_logs",
                                    data=data_crawl,
                                    condition=f"date = DATE('{date.strftime('%Y-%m-%d')}') and file_config_id = {config_id}"
                                    )
        print(f"File config id {config_id} is CRAWL_SUCCESS!")
