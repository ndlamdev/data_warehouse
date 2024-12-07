from datetime import datetime

from database import controller_connector
from send_mail import send_mail
from util import read_data_log, read_data_config_join_log


def load_data_staging(ids=None, date=datetime.now()):
    # 1. Đọc file_config_id, status và procedure_load_data_staging theo ngày
    config_and_logs = read_data_config_join_log(ids, file_configs_columns=['id', 'procedure_load_data_staging'],
                                                file_logs_columns=['status'],
                                                date=date)

    # 2. Duyệt các dòng dữ liệu đọc được.
    for row in range(config_and_logs.shape[0]):
        config_and_log = config_and_logs.iloc[row]
        config_id = config_and_log['fc.id']
        log = config_and_log['fl.status']
        procedure = config_and_log['fc.procedure_load_data_staging']

        # 3. log is None or log != "LOAD_FILE_SUCCESS"
        if log is None or log != "LOAD_FILE_SUCCESS":
            log = read_data_log([config_id], date)
            if log is None:
                print(f"Don't have any log for file config id {config_id}.")
                continue

            print(f"File config id have status: {log['status'][0]}.")
            continue

        try:
            # 4.1 Chạy câu procedure
            controller_connector.call_procedure(procedure, [date.strftime('%Y-%m-%d')])
            # 5. Gửi mail thông báo
            send_mail(subject=f"Load data staging for file config id {config_id} success",
                      content='Load data into staging for file config id {config_id} success!')
        except Exception as e:
            # 4.2 Cập nhật lại log thành trạng thái cũ
            controller_connector.update(table="file_logs",
                                        data={
                                            "status": log,
                                            "date_update": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                                        },
                                        condition=f"date = DATE('{date.strftime('%Y-%m-%d')}') and file_config_id = {config_id}")
            # 5. Gửi mail thông báo
            send_mail(subject=f"Load data staging for file config id {config_id} failed", content=e.__str__())
