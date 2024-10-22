from dotenv import load_dotenv
import os

base_url = None
is_paging = None

css_selector_view_more = None
css_selector_product_item = None
css_selector_button_closed_pop_up_get_link = None

css_selector_button_closed_pop_up = None
css_selector_title = None
css_selector_product_container = None
css_selector_specifications = None
css_selector_colors = None
css_selector_desks = None
css_selector_color_links = None
css_selector_desk_links = None
css_selector_images = None
css_selector_price = None
css_selector_status = None
css_selector_discount = None
css_selector_show_more = None
css_selector_group_specifications = None
css_selector_name_group_specifications = None
css_selector_row_specifications = None
css_selector_title_specifications = None
css_selector_value_specifications = None


def init_env(env):
    global base_url
    global is_paging

    global css_selector_view_more
    global css_selector_product_item
    global css_selector_button_closed_pop_up_get_link

    global css_selector_button_closed_pop_up
    global css_selector_title
    global css_selector_product_container
    global css_selector_specifications
    global css_selector_colors
    global css_selector_desks
    global css_selector_color_links
    global css_selector_desk_links
    global css_selector_images
    global css_selector_price
    global css_selector_status
    global css_selector_discount
    global css_selector_show_more
    global css_selector_group_specifications
    global css_selector_name_group_specifications
    global css_selector_row_specifications
    global css_selector_title_specifications
    global css_selector_value_specifications

    load_dotenv(f"{env}.env", override=True)

    base_url = os.getenv("URL")
    is_paging = os.getenv('IS_PAGING')

    css_selector_view_more = os.getenv('VIEW_MORE')
    css_selector_product_item = os.getenv('PRODUCT_ITEM')
    css_selector_button_closed_pop_up_get_link = os.getenv('BUTTON_CLOSED_POP_UP')

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
