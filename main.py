from datetime import datetime

from load_data_temp.main import load_file
from process_data.main import load_data_staging
from transform_data.main import transform_data

dt = datetime(2024, 12, 3)

print("="*20, "load file temp", "="*20)
load_file(date=dt)
print("="*20, "load data_staging", "="*20)
load_data_staging(date=dt)
print("="*20, "transform data", "="*20)
transform_data(date=dt)