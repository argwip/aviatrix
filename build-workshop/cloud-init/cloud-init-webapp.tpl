#cloud-config

# Install additional packages on first boot
#
package_update: true
packages:
 - git
 - apache2
 - python-pip

write_files:
  - path: /root/test.sh
    content: |
        #!/bin/bash

        git clone https://github.com/fkhademi/webapp-demo.git
        pip install pymysql
        a2dismod mpm_event
        a2enmod mpm_prefork cgi
        service apache2 restart
        mkdir /var/www/html/appdemo
        mkdir /etc/avx/
        cp webapp-demo/conf/${type}/000-default.conf /etc/apache2/sites-enabled/
        cp webapp-demo/conf/${type}/ports.conf /etc/apache2/
        cp webapp-demo/html/* /var/www/html/appdemo/
        cp webapp-demo/scripts/* /var/www/html/appdemo/
        cp webapp-demo/img/* /var/www/html/appdemo/

        echo "[avx-config]

        WebServerName = web.${pod_id}.avxlab.de
        #Enter the name of the app server or load balancer (DNS or IP address; DNS preferred)
        AppServerName = app.${pod_id}.avxlab.de
        #Enter the name of the MySQL server (DNS or IP address; DNS preferred)
        DBServerName = db.${pod_id}.avxlab.de
        MyFQDN = ${type}.${pod_id}.${domainname}" > /etc/avx/avx.conf

        service apache2 restart
             
runcmd:
  - bash /root/test.sh