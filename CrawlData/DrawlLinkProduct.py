from time import sleep
from dotenv import load_dotenv
import os

from CrawlData.CrawlDataHelpper import get_value, get_elements

load_dotenv()

css_selector_view_more = os.getenv('VIEW_MORE')
css_selector_product_item = os.getenv('PRODUCT_ITEM')
css_selector_button_closed_pop_up = os.getenv('BUTTON_CLOSED_POP_UP')


def crawl_link(driver):
    while True:
        view_more = get_elements(driver, css_selector_view_more)
        if view_more is None or view_more.text == '':
            break

        try:
            view_more.click()
        except Exception:
            get_elements(driver, css_selector_button_closed_pop_up).click()
            view_more.click()

        print("-------------View more------------")
        sleep(2)

    return get_value(driver, css_selector_product_item)
