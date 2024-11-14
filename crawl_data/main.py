import datetime

from crawl_data.src.main import crawl
from database import controller_connector
from util import read_data_config, read_data_log


def init_log(file_config_id, name, date):
    if not isinstance(date, datetime.datetime):
        raise Exception("date must be a datetime from datetime")

    controller_connector.create(table="file_logs",
                                data={
                                    'file_config_id': int(file_config_id),
                                    'file_name': f'{name}_{date.strftime('%Y-%m-%d')}',
                                    'status': 'CRAWLING',
                                    'date': date.strftime('%Y-%m-%d'),
                                    'date_update': datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
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


def crawl_data():
    date = datetime.datetime.now()
    configs = read_data_config()
    for row in range(configs.shape[0]):
        config = configs.iloc[row]
        config_id = config['id']
        log = read_data_log(config_ids=[config_id], date=date)
        if not log.empty and log['status'].values[0] == "CRAWL_SUCCESS":
            print(f"File config id {config_id} is CRAWL_SUCCESS!")
            continue

        name = config['name']
        crawl_data_product_css_selectors_id = configs.iloc[row]['crawl_data_product_css_selectors_id']
        crawl_link_css_selectors_id = configs.iloc[row]['crawl_link_css_selectors_id']

        if log.empty:
            init_log(config_id, name, date)
            print(f"File config id {config_id} init log success!")
        else:
            print(f"File config id {config_id} is {log['status'].values[0]}!")

        config_crawl_data = get_control_crawl_data_product_css_selectors_by_id(crawl_data_product_css_selectors_id)
        config_crawl_link = get_control_crawl_link_css_selectors_by_id(crawl_link_css_selectors_id)
        config_crawl_link['location_file_save'] = config['location_file_save']
        config_crawl_link['name'] = config['name']
        limit_product = config['limit_item']

        data_crawl = crawl(config_crawl_link, config_crawl_data, limit_product)

        controller_connector.update(table="file_logs",
                                    data=data_crawl,
                                    condition=f"date = DATE('{date.strftime('%Y-%m-%d')}') and file_config_id = {config_id}"
                                    )
        print(f"File config id {config_id} is CRAWL_SUCCESS!")


crawl_data()