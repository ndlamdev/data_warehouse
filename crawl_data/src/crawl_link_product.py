from time import sleep

from selenium.common import ElementClickInterceptedException

from crawl_data.src.crawl_data_helper import get_value, get_elements


def crawl_link(driver, config, limit_product=50):
    css_selector_button_closed_pop_up_get_link = config['button_close_pop_up']
    css_selector_view_more = config['view_more']
    css_selector_product_item = config['product_item']

    while limit_product > 0:
        links = get_value(driver, css_selector_product_item)
        if len(links) >= limit_product:
            return links[:limit_product]

        view_more = get_elements(driver, css_selector_view_more)
        if view_more is None or view_more.text == '':
            return links

        try:
            driver.execute_script("arguments[0].scrollIntoView(true);", view_more)
            sleep(0.5)
            view_more.click()
        except ElementClickInterceptedException:
            get_elements(driver, css_selector_button_closed_pop_up_get_link).click()
            view_more.click()

        print("-------------View more------------")
        sleep(2)

    return get_value(driver, css_selector_product_item)
