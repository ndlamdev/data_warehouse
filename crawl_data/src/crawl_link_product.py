from time import sleep

from selenium.common import ElementClickInterceptedException

from crawl_data.src.crawl_data_helper import get_value, get_elements


def crawl_link(driver, config, limit_product=50):
    css_selector_button_closed_pop_up_get_link = config['button_close_pop_up']
    css_selector_view_more = config['view_more']
    css_selector_product_item = config['product_item']

    while limit_product > 0:
        # 1. Cào dữ link sản phẩm
        links = get_value(driver, css_selector_product_item)
        # 2. Kiểm tra số lượng đủ chưa
        if len(links) >= limit_product:
            # 3. Trả về danh sách link theo số lượng
            return links[:limit_product]

        # 4. Lấy đối tượng nút 'Xem thêm'
        view_more = get_elements(driver, css_selector_view_more)
        # 5. None or button.text = ''
        if view_more is None or view_more.text == '':
            # 6. Trả danh sách link đã lấy được
            return links

        try:
            # 7. Cuộn trang đến nút 'Xem thêm'
            driver.execute_script("arguments[0].scrollIntoView(true);", view_more)
            sleep(0.5)
            # 8. Bấm nút 'Xem thêm'
            view_more.click()
        except ElementClickInterceptedException:  # 9. Lỗi
            # 10. Thử tắt dialog
            try:
                get_elements(driver, css_selector_button_closed_pop_up_get_link).click()
            except ElementClickInterceptedException:
                pass
            # 11. Bấm nút 'Xem thêm'
            try:
                view_more.click()
            except Exception:
                # 12. Trả danh sách link đã lấy được
                return links

        print("-------------View more------------")
        sleep(2)

    return get_value(driver, css_selector_product_item)
