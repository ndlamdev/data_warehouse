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

    # 1.Tạo driver để chạy
    options = Options()
    options.add_argument('--headless')
    driver = webdriver.Edge(options)
    driver.get(base_url)
    driver.fullscreen_window()

    # 2. lấy các link của sản phẩm
    links = crawl_link(driver, config_crawl_link, limit_product)

    products = []
    total_success = 0
    total_fail = 0
    for link in links:  # 3. Duyệt và từng link sản phẩm
        try:
            print("=" * 50, f"product: {len(products) + 1} / {len(links)}", "=" * 50)
            # 4. Cào dữ liệu sản phẩm từ link sản phẩm
            data = crawl_data_product(driver, link, config_crawl_product)
            # 6. kiểm tra trạng thái 'success'
            if data['status'] == 'success':
                # 6.2. Tăng số lượng sản phẩm cào thành công
                total_success += 1
            else:
                # 6.1.Tăng số lượng  sản phẩm cào thất bại
                total_fail += 1
        except Exception:  # 5. Có lỗi
            data = {'source': link, 'status': 'fail'}
            # 5.1.Tăng số lượng  sản phẩm cào thất bại
            total_fail += 1

        products.append(data)

        # 7. Cập nhật lại file giá
        (pd.DataFrame(data=[[product[column] for column in columns] for product in products if
                            product['status'] == 'success'],
                      columns=columns)
         .to_csv(f'{base_name}_{date.strftime("%Y-%m-%d")}.csv', index=False, encoding='utf-8'))

    driver.quit()
    # 8. Tra về dữ liệu cập nhật log
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
    # 1.Đọc dữ liệu file_config
    configs = read_data_config(ids)
    for row in range(configs.shape[0]):  # 2. Duyệt từng dòng dữ liệu của file_config
        config = configs.iloc[row]
        config_id = config['id']
        # 3.Kiểm tra log dự vào file_config_id và ngày
        log = read_data_log(config_ids=[config_id], date=date)
        if not log.empty and log['status'].values[0] != "CRAWL_FAIL":
            print(f"File config id {config_id} is ${log['status']}!")
            continue

        if log.empty:
            # 4. Ghi 1 dòng log với trạng thái 'CRAWLING'.
            init_log(config_id, name, date)
            print(f"File config id {config_id} init log success!")
        else:
            print(f"File config id {config_id} is {log['status'].values[0]}!")

            # 5. lấy tên file từ table file_config của database: database_control
        name = config['name']
        # 6. lấy vị trí lưu file từ table file_config của database: database_control
        location_file_save = config['location_file_save']
        # 7. lấy số lượng sản phẩm tối đa file_config của database: database_control
        limit_product = config['limit_item']
        # 8. lấy các css_selector_link table crawl_link_css_selectors của database: database_control
        config_crawl_link = get_control_crawl_link_css_selectors_by_id(config['crawl_link_css_selectors_id'])
        # 9. lấy các css_selector_product table crawl_data_product_css_selectors của database: database_control
        config_crawl_data = get_control_crawl_data_product_css_selectors_by_id(
            config['crawl_data_product_css_selectors_id'])

        try:
            # 10. Cào dữ liệu
            data_crawl = crawl(config_crawl_link, config_crawl_data, limit_product, name, location_file_save)
            # 11. Gửi mail thông báo
            send_mail(subject="Crawl data success", content=f"Craw data for file config id {config_id} success!")
            # 12. Cập nhật lại log.
            controller_connector.update(table="file_logs",
                                        data=data_crawl,
                                        condition=f"date = DATE('{date.strftime('%Y-%m-%d')}') and file_config_id = {config_id}"
                                        )
        except Exception as e:
            # 11. Gửi mail thông báo
            send_mail(subject="Crawl link fail", content=e.__str__())
            # 12. Cập nhật lại log.
            controller_connector.update(table="file_logs",
                                        data={
                                            "status": "CRAWL_FAIL",
                                            "date_update": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                                        },
                                        condition=f"date = DATE('{date.strftime('%Y-%m-%d')}') and file_config_id = {config_id}"
                                        )
