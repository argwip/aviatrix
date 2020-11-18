import requests
import json
import sys
import urllib3
import time
import socket

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

ctrl=sys.argv[1]
copilot=sys.argv[2]
ctrl_password=sys.argv[3]
cplt_user=sys.argv[4]
cplt_password=sys.argv[5]

ctrl_ip=socket.gethostbyname(ctrl)

# Create CoPilot session and add the cert
s = requests.Session()
set_copilot = {"controllerIp": ctrl_ip, "username": cplt_user, "password": cplt_password}
cplt_url = 'https://%s/login' % (copilot)
r = s.post(cplt_url, data=set_copilot, verify=False)

cplt_url = 'https://%s/addcertificate' % (copilot)
files = {'certificate': open('cert.pem', 'rb'), 'certificateKey': open('priv.pem', 'rb')}
r = s.post(cplt_url, files=files, verify=False)
print("CoPilot cert output: ", r.text)

##  Restart webapp
cplt_url = 'https://%s/services/restart/web' % (copilot)
try:
  r = s.get(cplt_url, verify=False)
except Exception:
  pass

## Upload Controller cert
url = "https://%s/v1/backend1" % (ctrl)
url2 = "https://%s/v1/api" % (ctrl)

get_cid = {"action": "login_proc", "username": "admin", "password": ctrl_password}
# Wait for the Controller API 
r = requests.post(url, data=get_cid, verify=False)
dict = json.loads(r.text)
print(r.text)

file_list = [
    ('ca_cert', ('ca.pem', open('./ca.pem', 'r'), 'txt/txt')),
    ('server_cert', ('cert.pem', open('./cert.pem', 'r'), 'txt/txt')),
    ('private_key', ('priv.pem', open('./priv.pem', 'r'), 'txt/txt'))
]
data = {"action": "import_new_https_certs", "CID": dict['CID']}
r = requests.post(url2, data=data, files=file_list, verify=False)
print("CTRL cert output: ", r.text)