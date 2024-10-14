from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.edge.options import Options
from dotenv import load_dotenv
import os

from CrawlData.CrawlDataProduct import crawl_data_product
from CrawlData.DrawlLinkProduct import crawl_link

load_dotenv()

base_url = os.getenv("URL")
is_paging = os.getenv('IS_PAGING')
css_selector_view_more = os.getenv('VIEW_MORE')
css_selector_product_item = os.getenv('PRODUCT_ITEM')


def run():
    options = Options()
    # options.add_argument('--headless')
    driver = webdriver.Edge(options)
    crawl_data_product(driver, 'https://www.thegioididong.com/dtdd/samsung-galaxy-s23-ultra-5g-512gb?utm_flashsale=1')
    # driver.get(base_url)
    # if is_paging == 'True':
    #     links = crawl_link(driver)
    #     print(links)
    #     for link in links:
    #         crawl_data_product(driver, link)


run()
