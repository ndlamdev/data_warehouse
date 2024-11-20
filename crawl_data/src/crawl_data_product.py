from time import sleep

from crawl_data.src.crawl_data_helper import get_value, get_elements


def crawl_data_product(driver, link, config_crawl_product):
    css_selector_button_closed_pop_up = config_crawl_product['button_close_pop_up']
    css_selector_title = config_crawl_product['title']
    css_selector_product_container = config_crawl_product['product_container']
    css_selector_colors = config_crawl_product['colors']
    css_selector_desks = config_crawl_product['desks']
    css_selector_images = config_crawl_product['images']
    css_selector_show_more = config_crawl_product['show_more_specifications']
    css_selector_group_specifications = config_crawl_product['group_specifications']
    css_selector_desk_links = config_crawl_product['desk_links']
    css_selector_color_links = config_crawl_product['color_links']
    css_selector_price = config_crawl_product['price']
    css_selector_discount = config_crawl_product['discount']
    css_selector_status = config_crawl_product['status']

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
        sleep(0.05)
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

    specifications = []
    group_specifications = get_elements(product, css_selector_group_specifications)
    if group_specifications is None:
        crawl_specification(driver, specifications, config_crawl_product)
    else:
        for group in group_specifications:
            group.click()
            crawl_specification(group, specifications, config_crawl_product)

    dictionary['specifications'] = specifications

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
                price_obj = get_price(driver, color_link, colors, index_color, config_crawl_product)
                price_obj['desk'] = desks[index_desk]
                prices.append(price_obj)
    elif len(colors) != 0 and len(desks) == 0:
        color_links = get_value(product, css_selector_color_links)
        for index_color in range(0, len(color_links)):
            color_link = color_links[index_color]
            price_obj = get_price(driver, color_link, colors, index_color, config_crawl_product)
            prices.append(price_obj)
    elif len(colors) == 0 and len(desks) != 0:
        desk_links = get_value(product, css_selector_desk_links)
        for index_desk in range(0, len(desk_links)):
            desk_link = desk_links[index_desk]
            price_obj = get_price(driver, desk_link, desks, index_desk, config_crawl_product)
            prices.append(price_obj)
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


def crawl_specification(container, specifications, config):
    css_selector_row_specifications = config['row_specifications']
    css_selector_title_specifications = config['title_specifications']
    css_selector_value_specifications = config['value_specifications']

    rows = get_elements(container, css_selector_row_specifications)
    for row in rows:
        title = get_value(row, css_selector_title_specifications)
        value = get_value(row, css_selector_value_specifications)

        specifications.append({title: value})


def     get_price(driver, link, collection, index, config):
    css_selector_button_closed_pop_up = config['button_close_pop_up']
    css_selector_product_container = config['product_container']
    css_selector_price = config['price']
    css_selector_discount = config['discount']
    css_selector_status = config['status']

    try:
        driver.get(link)
        try:
            get_elements(driver, css_selector_button_closed_pop_up).click()
        except Exception:
            pass
        product = get_elements(driver, css_selector_product_container)
        price = get_value(product, css_selector_price)
        discount = get_value(product, css_selector_discount)
        status = get_value(product, css_selector_status)
        return {
            "color": collection[index],
            "price_base": price,
            "discount": discount,
            "status": status
        }
    except Exception:
        pass
