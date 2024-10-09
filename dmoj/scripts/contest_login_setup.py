# use manage.py shell to run
import json
import secrets
import string

from judge.models import *
from django.core.mail import *
from django.contrib.auth.models import User
from django.conf import settings


# Must be updated between runs when using email batches
FILE_START_NUM = 0  # File offset
USER_START_NUM = 1100 # Latest team number (after file offset included)

FILE = "lcc2023-11.json"  # Must be json with {"team name": [{"name": "", "email": "", "school": ""}, ...], ...}
COMPETITION = "LCC23"  # ex. 'Moose' or 'LCC'
ORG_ID = 22  # Organization pk, not slug
FROM_EMAIL = settings.DEFAULT_FROM_EMAIL
MAIL_LIMIT = 300

SUBJECT = "LCC Team Login Information"
MESSAGE = """Hi,

Thank you for signing up for the 2023 LCC competitive programming competition. Below you will find your team's credentials for logging in:

Username: {user}
Password: {pass}
Login: https://mcpt.ca/accounts/login/
Contests: https://mcpt.ca/contests/

You will have to log in beforehand and register for the appropriate contest by clicking "Register" on the contest page.

Below are the links to the next contests (you might not be able to view the contest until the day of):

Junior: https://mcpt.ca/contest/lcc23c2j
Senior: https://mcpt.ca/contest/lcc23c2s

We hope you enjoy the contest!

This is an automated message. If you have any questions or concerns, please contact presidents@mcpt.ca.
"""

def send(real=False):
    org = Organization.objects.get(id=ORG_ID)
    with open(FILE, "r") as f:
        data = json.loads(f.read())

    mails_sent = 0
    num = 0
    for team, users in data .items():
        num += 1
        if num < FILE_START_NUM:
            continue

        mails_sent += len(users)
        if mails_sent > MAIL_LIMIT:
            print("Sent %d mails" % (mails_sent - len(users)))
            print("Next team:  %s)" % team)
            print("Update 'FILE_START_NUM' in the script to: %d" % num)
            return

        username = "%s_%s_%d" % (COMPETITION, team, num + USER_START_NUM-1)
        password = ''.join(secrets.choice(string.ascii_letters + string.digits) for i in range(16))
        print("Making user: (%s, %s)" % (username, password))
        if real:
            usr = User.objects.create_user(username, password=password)
            profile = Profile(user=usr, is_external_user=True)

        msg = MESSAGE.format(**{"user": username, "pass": password, "team": team})
        emails = []
        notes = ""
        for user in users:
            emails.append(user["email"])
            notes += "%s <%s>\n" % (user["name"], user["email"])

        email = EmailMessage(SUBJECT, msg, FROM_EMAIL, [], emails)
        print("Preparing message: %s" % emails)
        if real:
            profile.notes = notes
            profile.save()
            profile.organizations.add(org)
            email.send()
            print('email sent')
