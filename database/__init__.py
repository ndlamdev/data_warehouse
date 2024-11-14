from database.DatabaseConnectHelper import DatabaseConnectHelper
from database.config.env import CONTROLLER_DB_HOST, CONTROLLER_DB_PORT, CONTROLLER_DB_NAME, CONTROLLER_DB_USER, \
    CONTROLLER_DB_PASS, CONTROLLER_DB_POOL_NAME, CONTROLLER_DB_POOL_SIZE

controller_connector = DatabaseConnectHelper(
    host=CONTROLLER_DB_HOST,
    port=CONTROLLER_DB_PORT,
    database=CONTROLLER_DB_NAME,
    user=CONTROLLER_DB_USER,
    password=CONTROLLER_DB_PASS,
    pool_name=CONTROLLER_DB_POOL_NAME,
    pool_size=CONTROLLER_DB_POOL_SIZE
)
