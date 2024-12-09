from selenium.webdriver.common.by import By


def split_group(group):
    return '; '.join([tag_a.text for tag_a in group.find_elements(By.CSS_SELECTOR, 'a')])


def get_value(driver, name=''):
    try:
        is_list = name[-2:]
        if is_list == '@s':
            name = name[:-2]
            try:
                if name.endswith(']'):
                    att = name[name.index('[') + 1:len(name) - 1]
                    elements = driver.find_elements(By.CSS_SELECTOR, name[:name.index('[')])
                    result = [element.get_attribute(att) for element in elements]
                else:
                    elements = driver.find_elements(By.CSS_SELECTOR, name)
                    result = [element.text for element in elements]

                if len(result) == 1:
                    return result[0]
                return result
            except Exception:
                return []

        return driver.find_element(By.CSS_SELECTOR, name).text
    except Exception:
        return ""


def get_elements(driver, name):
    try:
        is_list = name[-2:]
        if is_list == '@s':
            return driver.find_elements(By.CSS_SELECTOR, name[:-2])
        return driver.find_element(By.CSS_SELECTOR, name)
    except Exception:
        return None
