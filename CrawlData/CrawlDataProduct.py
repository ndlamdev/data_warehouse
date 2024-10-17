from time import sleep

from dotenv import load_dotenv
from CrawlData.CrawlDataHelpper import get_value, get_elements
import os

load_dotenv()

css_selector_button_closed_pop_up = os.getenv('BUTTON_CLOSED_POP_UP_PRODUCT')
css_selector_title = os.getenv("TITLE")
css_selector_product_container = os.getenv("PRODUCT_CONTAINER")
css_selector_specifications = os.getenv("SPECIFICATIONS_CONTAINER")
css_selector_colors = os.getenv('COLORS')
css_selector_desks = os.getenv('DESKS')
css_selector_color_links = os.getenv('COLOR_LINKS')
css_selector_desk_links = os.getenv('DESK_LINKS')
css_selector_images = os.getenv('IMAGES')
css_selector_price = os.getenv('PRICE')
css_selector_status = os.getenv('STATUS')
css_selector_discount = os.getenv('DISCOUNT')
css_selector_show_more = os.getenv("SHOW_MORE_SPECIFICATIONS")
css_selector_group_specifications = os.getenv("GROUP_SPECIFICATIONS")
css_selector_name_group_specifications = os.getenv("NAME_GROUP_SPECIFICATIONS")
css_selector_row_specifications = os.getenv("ROW_SPECIFICATIONS")
css_selector_title_specifications = os.getenv("TITLE_SPECIFICATIONS")
css_selector_value_specifications = os.getenv("VALUE_SPECIFICATIONS")


def crawl_data_product(driver, link):
    print("=" * 100)
    dictionary = {'source': link, 'status': "success"}
    driver.get(link)
    try:
        get_elements(driver, css_selector_button_closed_pop_up).click()
    except Exception:
        pass

    try:
        name = get_value(driver, css_selector_title)
        product = get_elements(driver, css_selector_product_container)
        print(name)
        dictionary['name'] = name
    except NameError:
        return {'source': link, 'status': "fail"}

    scroll_height = driver.execute_script("return document.body.scrollHeight")
    current_position = 0
    scroll_increment = 100
    while current_position < scroll_height:
        driver.execute_script(f"window.scrollBy(0, {scroll_increment});")
        current_position += scroll_increment
        sleep(0.01)
    sleep(2)

    colors = get_value(product, css_selector_colors)
    desks = get_value(product, css_selector_desks)
    dictionary['desks'] = desks
    dictionary['colors'] = colors

    images = get_value(product, css_selector_images)
    dictionary['images'] = images

    show_more = get_elements(product, css_selector_show_more)
    if show_more is not None:
        show_more.click()
        sleep(2)

    group_specificationss = get_elements(product, css_selector_group_specifications)
    if group_specificationss is None:
        rows = get_elements(product, css_selector_row_specifications)
        for row in rows:
            title = get_value(row, css_selector_title_specifications)
            value = get_value(row, css_selector_value_specifications)
            print(f'{title} | {value}')
        return

    technical = []
    for group in group_specificationss:
        group_technical = {}
        group.click()
        name_group = get_value(group, css_selector_name_group_specifications)
        group_technical['name'] = name_group
        rows = get_elements(group, css_selector_row_specifications)
        data = {}
        for row in rows:
            title = get_value(row, css_selector_title_specifications)
            value = get_value(row, css_selector_value_specifications)
            data[title] = value

        group_technical['data'] = data
        technical.append(group_technical)

    dictionary['specifications'] = technical

    prices = []
    price_obj = {}
    if len(colors) != 0 and len(desks) != 0:
        disk_links = get_value(product, css_selector_desk_links)
        for index_desk in range(0, len(disk_links)):
            disk_link = disk_links[index_desk]
            driver.get(disk_link)
            try:
                get_elements(driver, css_selector_button_closed_pop_up).click()
            except Exception:
                pass
            product = get_elements(driver, css_selector_product_container)
            color_links = get_value(product, css_selector_color_links)
            for index_color in range(0, len(color_links)):
                color_link = color_links[index_color]
                try:
                    driver.get(color_link)
                    try:
                        get_elements(driver, css_selector_button_closed_pop_up).click()
                    except Exception:
                        pass
                    product = get_elements(driver, css_selector_product_container)
                    price = get_value(product, css_selector_price)
                    discount = get_value(product, css_selector_discount)
                    status = get_value(product, css_selector_status)
                    price_obj['color'] = colors[index_desk]
                    price_obj['desk'] = desks[index_desk]
                    price_obj['price_base'] = price
                    price_obj['discount'] = discount
                    price_obj['status'] = status
                    prices.append(price_obj)
                except Exception:
                    continue
    elif len(colors) != 0 and len(desks) == 0:
        color_links = get_value(product, css_selector_color_links)
        for index_color in range(0, len(color_links)):
            color_link = color_links[index_color]
            try:
                driver.get(color_link)
                try:
                    get_elements(driver, css_selector_button_closed_pop_up).click()
                except Exception:
                    pass
                product = get_elements(driver, css_selector_product_container)
                price = get_value(product, css_selector_price)
                discount = get_value(product, css_selector_discount)
                status = get_value(product, css_selector_status)
                price_obj['color'] = colors[index_color]
                price_obj['price_base'] = price
                price_obj['discount'] = discount
                price_obj['status'] = status
                prices.append(price_obj)
            except Exception:
                continue
    elif len(colors) == 0 and len(desks) != 0:
        desk_links = get_value(product, css_selector_desk_links)
        for index_desk in range(0, len(desk_links)):
            desk_link = desk_links[index_desk]
            try:
                driver.get(desk_link)
                try:
                    get_elements(driver, css_selector_button_closed_pop_up).click()
                except Exception:
                    pass
                product = get_elements(driver, css_selector_product_container)
                price = get_value(product, css_selector_price)
                discount = get_value(product, css_selector_discount)
                status = get_value(product, css_selector_status)
                price_obj['desk'] = desks[index_desk]
                price_obj['price_base'] = price
                price_obj['discount'] = discount
                price_obj['status'] = status
                prices.append(price_obj)
            except Exception:
                continue
    else:
        price = get_value(product, css_selector_price)
        discount = get_value(product, css_selector_discount)
        status = get_value(product, css_selector_status)
        price_obj['price_base'] = price
        price_obj['discount'] = discount
        price_obj['status'] = status
        prices.append(price_obj)

    dictionary['prices'] = prices
    return dictionary
