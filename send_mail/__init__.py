import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from send_mail.config.env import EMAIL, EMAIL_PASS, DEST_EMAIL


def send_mail(dest=None, subject='', content=''):
    if dest is not None:
        send_mail_helper(dest, subject, content)

    for dest in DEST_EMAIL.split(";"):
        send_mail_helper(dest, subject, content)


def send_mail_helper(dest, subject, content):
    msg = MIMEMultipart()
    msg['From'] = EMAIL
    msg['To'] = dest
    msg['Subject'] = subject
    # Attach the email body
    msg.attach(MIMEText(content, 'plain'))

    try:
        # Set up the server and send the email
        with smtplib.SMTP('smtp.gmail.com', 587) as server:
            server.starttls()
            server.login(EMAIL, EMAIL_PASS)
            server.sendmail(EMAIL, dest, msg.as_string())
        print("Email sent successfully.")
    except Exception as e:
        print(f"Failed to send email: {e}")
