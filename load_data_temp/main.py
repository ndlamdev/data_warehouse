from datetime import datetime

from database import controller_connector
from send_mail import send_mail
from util import read_data_config_join_log


def load_file(ids=None, date=datetime.now()):
    config_and_logs = read_data_config_join_log(ids, file_configs_columns=['id', 'procedure_load_data_temp'],
                                                file_logs_columns=['status'],
                                                date=date)

    for row in range(config_and_logs.shape[0]):
        config_and_log = config_and_logs.iloc[row]
        config_id = config_and_log['fc.id']
        log = config_and_log['fl.status']
        procedure = config_and_log['fc.procedure_load_data_temp']

        result = controller_connector.call_procedure(procedure, [int(config_id), date.strftime('%Y-%m-%d')])

        if result is None:
            if log is None:
                print(f"Don't have any log for file config id {config_id}.")
                continue

            print(f"File config id have status: {log}.")
            continue

        try:
            for sql in result[0]:
                controller_connector.run_sql(sql)
        except Exception as e:
            send_mail(subject="Load file fail", content=e.__str__())
            controller_connector.update(table="file_logs",
                                        data={
                                            "status": log,
                                            "date_update": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                                        },
                                        condition=f"date = DATE('{date.strftime('%Y-%m-%d')}') and file_config_id = {config_id}")
            continue

        send_mail(subject="Load file success", content='Load file for file config id {config_id} success!')


load_file()
