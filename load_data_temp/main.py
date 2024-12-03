from datetime import datetime

from database import controller_connector
from send_mail import send_mail
from util import read_data_config_join_log


def load_file(ids=None, date=datetime.now()):
    # 1. Đọc file_config_id, trạng thái và procedure load file theo ngày
    config_and_logs = read_data_config_join_log(ids, file_configs_columns=['id', 'procedure_load_data_temp'],
                                                file_logs_columns=['status'],
                                                date=date)

    # 2. Duyệt các dòng dữ liệu đọc được.
    for row in range(config_and_logs.shape[0]):
        config_and_log = config_and_logs.iloc[row]
        config_id = config_and_log['fc.id']
        log = config_and_log['fl.status']

        procedure = config_and_log['fc.procedure_load_data_temp']

        # 3. Chạy câu lệnh procedure
        result = controller_connector.call_procedure(procedure, [int(config_id), date.strftime('%Y-%m-%d')])

        # 4. Kiểm tra câu lệnh có null
        if result is None:
            if log is None:
                print(f"Don't have any log for file config id {config_id}.")
                continue

            print(f"File config id have status: {log}.")
            continue

        try:
            # 5. Duyệt qua các dòng sql nhận được từ procedure
            for sql in result[0]:
                # 6. Chạy các câu lệnh sql
                controller_connector.run_sql(sql)
            # 7.2.1. Gửi mail lỗi
            send_mail(subject=f"Load file for file config id {config_id} success",
                      content='Load file for file config id {config_id} success!')
        except Exception as e:  # 7. Lỗi
            # 7.1.1. Gửi mail lỗi
            send_mail(subject=f"Load file for file config id {config_id} failed", content=e.__str__())
            # 7.1.2. Cập nhật lại log
            controller_connector.update(table="file_logs",
                                        data={
                                            "status": log,
                                            "date_update": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                                        },
                                        condition=f"date = DATE('{date.strftime('%Y-%m-%d')}') and file_config_id = {config_id}")


load_file()
