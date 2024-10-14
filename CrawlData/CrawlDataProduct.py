from time import sleep

from dotenv import load_dotenv
from CrawlData.CrawlDataHelpper import get_value, get_elements
import os

load_dotenv()

css_selector_title = os.getenv("TITLE")
css_selector_product_container = os.getenv("PRODUCT_CONTAINER")
css_selector_description = os.getenv("DESCRIPTION_CONTAINER")
css_selector_colors = os.getenv('COLORS')
css_selector_disks = os.getenv('DISKS')
css_selector_images = os.getenv('IMAGES')
css_selector_price = os.getenv('PRICE')
css_selector_discount = os.getenv('DISCOUNT')
css_selector_show_more = os.getenv("SHOW_MORE_DESCRIPTION")
css_selector_group_description = os.getenv("GROUP_DESCRIPTION")
css_selector_name_group_description = os.getenv("NAME_GROUP_DESCRIPTION")
css_selector_row_description = os.getenv("ROW_DESCRIPTION")
css_selector_title_description = os.getenv("TITLE_DESCRIPTION")
css_selector_value_description = os.getenv("VALUE_DESCRIPTION")


def crawl_data_product(driver, link):
    print("=" * 100)
    try:
        driver.get(link)
        name = get_value(driver, css_selector_title)
        product = get_elements(driver, css_selector_product_container)
        print(name)
    except NameError:
        return

        # Lấy chiều cao của trang
    scroll_height = driver.execute_script("return document.body.scrollHeight")

    # Thiết lập vị trí bắt đầu cuộn
    current_position = 0

    # Đặt khoảng cách cuộn mỗi lần (ví dụ: 100 pixels)
    scroll_increment = 100

    # Cuộn từ từ từ trên xuống dưới
    while current_position < scroll_height:
        driver.execute_script(f"window.scrollBy(0, {scroll_increment});")

        # Tăng vị trí hiện tại
        current_position += scroll_increment

        sleep(0.1)  # Bạn có thể điều chỉnh thời gian này cho phù hợp

    colors = get_value(driver, css_selector_colors)
    disks = get_value(driver, css_selector_disks)
    print(f'Disk: {disks}')
    print(f'Color: {colors}')

    price = get_value(product, css_selector_price)
    discount = get_value(product, css_selector_discount)
    print(f'price: {price}')
    print(f'discount: {discount}')

    images = get_value(product, css_selector_images)
    for img in images:
        print(img)

    show_more = get_elements(product, css_selector_show_more)
    if show_more is not None:
        show_more.click()
        sleep(2)

    group_descriptions = get_elements(product, css_selector_group_description)
    if group_descriptions is None:
        rows = get_elements(product, css_selector_row_description)
        for row in rows:
            title = get_value(row, css_selector_title_description)
            value = get_value(row, css_selector_value_description)
            print(f'{title} | {value}')
        return

    for group in group_descriptions:
        group.click()
        name_group = get_value(group, css_selector_name_group_description)
        print(f"Group description: {name_group}")
        rows = get_elements(group, css_selector_row_description)
        for row in rows:
            title = get_value(row, css_selector_title_description)
            value = get_value(row, css_selector_value_description)
            print(f'{title} | {value}')
