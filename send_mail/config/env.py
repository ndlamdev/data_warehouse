from dotenv import load_dotenv
import os

load_dotenv(override=True)

EMAIL = os.getenv("EMAIL")
EMAIL_PASS = os.getenv("EMAIL_PASS")
DEST_EMAIL = os.getenv("DEST_EMAIL")
