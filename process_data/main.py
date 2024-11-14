from datetime import datetime

from database import controller_connector
from util import read_data_config, read_data_log


def load_file():
    configs = read_data_config()

    for row in range(configs.shape[0]):
        config = configs.iloc[row]
        config_id = config['id']
        log = read_data_log([config_id], datetime.now())

        if log is None or log['status'][0] != "LOAD_FILE_SUCCESS":
            log = read_data_log([config_id], datetime.now())
            if log is None:
                print(f"Don't have any log for file config id {config_id}.")
                continue

            print(f"File config id have status: {log['status'][0]}.")
            continue

        controller_connector.call_procedure(config['procedure_load_data_daily'])
load_file()
