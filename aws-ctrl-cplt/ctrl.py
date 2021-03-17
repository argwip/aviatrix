import requests
import json
import sys
import urllib3
import time
#import re

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

ctrl=sys.argv[1]
priv_ip=sys.argv[2]
copilot=sys.argv[3]
pw=sys.argv[4]
version=sys.argv[5]
customer_id=sys.argv[6]
cplt_license=sys.argv[7]
email_address=sys.argv[8]

url = "https://%s/v1/backend1" % (ctrl)
url2 = "https://%s/v1/api" % (ctrl)

get_cid = {"action": "login_proc", "username": "admin", "password": priv_ip}
# Wait for the Controller API 
r = None
while r is None:
  try:
    r = requests.post(url, data=get_cid, verify=False)
  except:
    pass

dict = json.loads(r.text)
print(r.text)

add_email = {"action": "add_admin_email_addr", "admin_email": email_address, "CID": dict['CID']}
r = requests.post(url2, data=add_email, verify=False)
print(r.text)

change_pw = {"action": "edit_account_user", "what": "password", "username": "admin", "old_password": priv_ip, "new_password": pw, "CID": dict['CID']}
r = requests.post(url2, data=change_pw, verify=False)
print(r.text)

random_step = {"action": "setup_network_options", "subaction": "cancel", "CID": dict['CID']}
r = requests.post(url2, data=random_step, verify=False)
print(r.text)

upgrade = {"action": "upgrade", "CID": dict['CID'], "version": version}
r = requests.post(url2, data=upgrade, verify=False)
print(r.text)

# Set Co-Pilot Password and License
s = requests.Session()
set_copilot = {"controllerIp": ctrl, "username": "admin", "password": pw}

cplt_url = 'https://%s/login' % (copilot)
r = s.post(cplt_url, data=set_copilot, verify=False)

cplt_url = 'https://%s/setlicense' % (copilot)
set_cplt_license = {"customerId": cplt_license}
r = s.post(cplt_url, data=set_cplt_license, verify=False)
print(r.text)
## Upload cert and key CoPilot
cplt_url = 'https://%s/addcertificate' % (copilot)
files = {'certificate': open('certificate.pem', 'rb'), 'certificateKey': open('private_key.pem', 'rb')}
r = s.post(cplt_url, files=files, verify=False)
print(r.text)
##  Restart webapp
cplt_url = 'https://%s/services/restart/web' % (copilot)
try:
  r = s.get(cplt_url, verify=False)
except Exception:
  pass

# Set Netflow Agent on Controller
get_cid = {"action": "login_proc", "username": "admin", "password": pw}
r = requests.post(url, data=get_cid, verify=False)
dict = json.loads(r.text)
print(r.text)

enable_netflow = {"action": "enable_netflow_agent", "CID": dict['CID'], "server_ip": copilot, "port": "31283", "version": "9", "exclude_gateway_list": ""}
r = requests.post(url2, data=enable_netflow, verify=False)
print(r.text)

set_customer_id = {"action": "setup_customer_id", "CID": dict['CID'], "customer_id": customer_id}
r = requests.post(url2, data=set_customer_id, verify=False)
print(r.text)

## Upload Controller cert
file_list = [
    ('ca_cert', ('ca_cert.pem', open('./ca_cert.pem', 'r'), 'txt/txt')),
    ('server_cert', ('certificate.pem', open('./certificate.pem', 'r'), 'txt/txt')),
    ('private_key', ('private_key.pem', open('./private_key.pem', 'r'), 'txt/txt'))
]
data = {"action": "import_new_https_certs", "CID": dict['CID']}
r = requests.post(url2, data=data, files=file_list, verify=False)
print(r.text)