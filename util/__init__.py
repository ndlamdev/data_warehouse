import datetime

import numpy as np
import pandas as pd

from database import controller_connector


def read_data_config(ids=None):
    if not ids is None and not isinstance(ids, list):
        raise Exception("ids must be an array or a list ar None")

    condition_get_data_configs = "" if ids is None else f"id in {tuple(ids)}" if \
        len(ids) > 1 else f"id = {ids[0]}"

    columns = ['id',
               'name',
               'location_file_save',
               'format_file',
               'database_staging',
               'database_warehouse',
               'table_warehouse',
               'column_table_warehouse',
               'table_staging',
               'column_table_staging',
               'limit_item',
               'crawl_link_css_selectors_id',
               'crawl_data_product_css_selectors_id',
               'procedure_load_data_temp',
               'procedure_load_data_daily'
               ]

    return pd.DataFrame(columns=columns,
                        data=controller_connector.read(table="file_configs", columns=', '.join(columns),
                                                       condition=condition_get_data_configs))


def read_data_log(config_ids=None, date=datetime.datetime.today()):
    if config_ids is None:
        config_ids = read_data_config()['name'].values
    if not isinstance(config_ids, list):
        raise Exception("ids must be an array or a list ar None")
    if not isinstance(date, datetime.datetime):
        raise Exception("date must be a datetime from datetime")

    condition_get_data_log = f"file_config_id in {tuple(config_ids)}" if \
        len(config_ids) > 1 else f"file_config_id = {config_ids[0]}" if len(config_ids) == 1 else ""

    condition_get_data_log += f" and date = '{date.strftime('%Y-%m-%d')}'" if len(
        condition_get_data_log) != 0 else f"date = '{date.strftime('%Y-%m-%d')}'"

    data_log = controller_connector.read(table="file_logs",
                                         condition=condition_get_data_log, )
    columns = [
        'id',
        'file_config_id',
        'file_name',
        'status',
        'date',
        'date_update',
        'total_crawl',
        'total_crawl_success',
        'total_crawl_fail',
    ]

    return pd.DataFrame(data_log, columns=columns)


def read_data_config_join_log(ids=None, file_configs_columns=None, file_logs_columns=None,
                              date=datetime.datetime.today()):
    if file_configs_columns is None or file_configs_columns == []:
        file_configs_columns = ['id',
                                'name',
                                'location_file_save',
                                'format_file',
                                'database_staging',
                                'database_warehouse',
                                'table_warehouse',
                                'column_table_warehouse',
                                'table_staging',
                                'column_table_staging',
                                'limit_item',
                                'crawl_link_css_selectors_id',
                                'crawl_data_product_css_selectors_id',
                                'procedure_load_data_temp',
                                'procedure_load_data_daily']

    if file_logs_columns is None or file_logs_columns == []:
        file_logs_columns = [
            'id',
            'file_config_id',
            'file_name',
            'status',
            'date',
            'date_update',
            'total_crawl',
            'total_crawl_success',
            'total_crawl_fail',
        ]

    file_configs_columns = ['fc.' + text for text in file_configs_columns]
    file_logs_columns = ['fl.' + text for text in file_logs_columns]

    coloumns = np.concatenate((file_configs_columns, file_logs_columns))
    data = controller_connector.read(
        custom_query=f"select {', '.join(coloumns)} \
                                                           from data_warehouse_control.file_configs as fc left join data_warehouse_control.file_logs fl on fc.id = fl.file_config_id \
                                                           where fl.date = '{date.strftime('%Y-%m-%d')}' {';' if ids == None else ' and fc.id in ' + tuple(ids) + ';'}",

    )

    return pd.DataFrame(data, columns=coloumns)
