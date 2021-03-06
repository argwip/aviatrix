#cloud-config

# Install additional packages on first boot
#
package_update: true
packages:
 - xrdp
 - lxde
 - make
 - gcc 
 - g++ 
 - libcairo2-dev
 - libjpeg-turbo8-dev
 - libpng-dev
 - libtool-bin
 - libossp-uuid-dev
 - libavcodec-dev
 - libavutil-dev
 - libswscale-dev
 - freerdp2-dev
 - libpango1.0-dev
 - libssh2-1-dev
 - libvncserver-dev
 - libtelnet-dev
 - libssl-dev
 - libvorbis-dev
 - libwebp-dev
 - tomcat9
 - tomcat9-admin
 - tomcat9-common
 - tomcat9-user
 - nginx

write_files:
  - path: /root/test.sh
    content: |
        #!/bin/bash

        systemctl start tomcat9
        systemctl enable tomcat9
        wget https://downloads.apache.org/guacamole/1.1.0/source/guacamole-server-1.1.0.tar.gz
        tar -xvzf guacamole-server-1.1.0.tar.gz
        cd guacamole-server-1.1.0
        ./configure --with-init-dir=/etc/init.d
        make
        make install
        ldconfig
        systemctl enable guacd
        systemctl start guacd
        wget https://mirrors.estointernet.in/apache/guacamole/1.1.0/binary/guacamole-1.1.0.war
        mkdir /etc/guacamole
        mv guacamole-1.1.0.war /etc/guacamole/guacamole.war
        ln -s /etc/guacamole/guacamole.war /var/lib/tomcat9/webapps/
        systemctl restart tomcat9
        systemctl restart guacd
        echo "guacd-hostname: localhost" >> /etc/guacamole/guacamole.properties
        echo "guacd-port:    4822" >> /etc/guacamole/guacamole.properties
        echo "user-mapping:    /etc/guacamole/user-mapping.xml" >> /etc/guacamole/guacamole.properties
        echo "auth-provider:    net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider" >> /etc/guacamole/guacamole.properties
        mkdir /etc/guacamole/{extensions,lib}
        echo "GUACAMOLE_HOME=/etc/guacamole" >> /etc/default/tomcat9
        echo "<user-mapping>" >> /etc/guacamole/user-mapping.xml
        echo "<authorize " >> /etc/guacamole/user-mapping.xml
        echo "username=\"${username}\"" >> /etc/guacamole/user-mapping.xml
        echo "password=\"${password}\">" >> /etc/guacamole/user-mapping.xml
        echo "<connection name=\"ssh server\">" >> /etc/guacamole/user-mapping.xml
        echo "<protocol>ssh</protocol>" >> /etc/guacamole/user-mapping.xml
        echo "<param name=\"hostname\">localhost</param>" >> /etc/guacamole/user-mapping.xml
        echo "<param name=\"port\">22</param>" >> /etc/guacamole/user-mapping.xml
        echo "</connection>" >> /etc/guacamole/user-mapping.xml
        echo "<connection name=\"gui server\">" >> /etc/guacamole/user-mapping.xml
        echo "<protocol>rdp</protocol>" >> /etc/guacamole/user-mapping.xml
        echo "<param name=\"hostname\">localhost</param>" >> /etc/guacamole/user-mapping.xml
        echo "<param name=\"port\">3389</param>" >> /etc/guacamole/user-mapping.xml
        echo "<param name=\"username\">${username}</param>" >> /etc/guacamole/user-mapping.xml
        echo "<param name=\"password\">${password}</param>" >> /etc/guacamole/user-mapping.xml
        echo "</connection>" >> /etc/guacamole/user-mapping.xml
        echo "</authorize>" >> /etc/guacamole/user-mapping.xml
        echo "</user-mapping>" >> /etc/guacamole/user-mapping.xml

        systemctl restart tomcat9
        systemctl restart guacd

        useradd -m -s /bin/bash ${username}
        chpasswd << 'END'
        ${username}:${password}
        END
        wget https://avx-build.s3.eu-central-1.amazonaws.com/${pod_id}-cert.crt
        wget https://avx-build.s3.eu-central-1.amazonaws.com/${pod_id}-cert.key
        cp ${pod_id}-cert.crt /etc/nginx/cert.crt
        cp ${pod_id}-cert.key /etc/nginx/cert.key
        #openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=DE/ST=BW/L=Schwetzingen/O=Aviatrix/CN=lab.avxlab.de" -keyout /etc/nginx/cert.key -out /etc/nginx/cert.crt
        systemctl start nginx
        systemctl enable nginx

        # Create Desktop shortcuts
        mkdir /home/${username}/Desktop
        echo "[Desktop Entry]" >> /home/${username}/Desktop/firefox.desktop
        echo "Type=Link" >> /home/${username}/Desktop/firefox.desktop
        echo "Name=Firefox Web Browser" >> /home/${username}/Desktop/firefox.desktop
        echo "Icon=firefox" >> /home/${username}/Desktop/firefox.desktop
        echo "URL=/usr/share/applications/firefox.desktop" >> /home/${username}/Desktop/firefox.desktop
        echo "[Desktop Entry]" >> /home/${username}/Desktop/lxterminal.desktop
        echo "Type=Link" >> /home/${username}/Desktop/lxterminal.desktop
        echo "Name=LXTerminal" >> /home/${username}/Desktop/lxterminal.desktop
        echo "Icon=lxterminal" >> /home/${username}/Desktop/lxterminal.desktop
        echo "URL=/usr/share/applications/lxterminal.desktop" >> /home/${username}/Desktop/lxterminal.desktop
        chown ${username}:${username} /home/${username}/Desktop
        chown ${username}:${username} /home/${username}/Desktop/*

        # Nginx config - SSL redirect
        echo "server {" >> /etc/nginx/conf.d/default.conf
        echo "    listen 80;" >> /etc/nginx/conf.d/default.conf
        echo "	  server_name ${hostname};" >> /etc/nginx/conf.d/default.conf
        echo "    return 301 https://\$host\$request_uri;" >> /etc/nginx/conf.d/default.conf
        echo "}" >> /etc/nginx/conf.d/default.conf
        echo "server {" >> /etc/nginx/conf.d/default.conf
        echo "	listen 443 ssl;" >> /etc/nginx/conf.d/default.conf
        echo "	server_name ${hostname};" >> /etc/nginx/conf.d/default.conf

        echo "  ssl_certificate /etc/nginx/cert.crt;" >> /etc/nginx/conf.d/default.conf
        echo "	ssl_certificate_key /etc/nginx/cert.key;" >> /etc/nginx/conf.d/default.conf
        echo "	ssl_protocols TLSv1.2;" >> /etc/nginx/conf.d/default.conf
        echo "	ssl_prefer_server_ciphers on; " >> /etc/nginx/conf.d/default.conf
        echo "	add_header X-Frame-Options DENY;" >> /etc/nginx/conf.d/default.conf
        echo "	add_header X-Content-Type-Options nosniff;" >> /etc/nginx/conf.d/default.conf
        echo "	add_header X-XSS-Protection "1; mode=block";" >> /etc/nginx/conf.d/default.conf

        echo "	access_log  /var/log/nginx/guac_access.log;" >> /etc/nginx/conf.d/default.conf
        echo "	error_log  /var/log/nginx/guac_error.log;" >> /etc/nginx/conf.d/default.conf

        echo "	location / {" >> /etc/nginx/conf.d/default.conf
        echo "		    proxy_pass http://localhost:8080/guacamole/;" >> /etc/nginx/conf.d/default.conf
        echo "		    proxy_buffering off;" >> /etc/nginx/conf.d/default.conf
        echo "		    proxy_http_version 1.1;" >> /etc/nginx/conf.d/default.conf
        echo "		    proxy_cookie_path /guacamole/ /;" >> /etc/nginx/conf.d/default.conf
        echo "	}" >> /etc/nginx/conf.d/default.conf
        echo "}" >> /etc/nginx/conf.d/default.conf
        systemctl restart nginx

        # Customize Guacamole login page
        wget https://avx-build.s3.eu-central-1.amazonaws.com/logo-144.png
        wget https://avx-build.s3.eu-central-1.amazonaws.com/logo-64.png
        while [ ! -d /var/lib/tomcat9/webapps/guacamole/images/ ]; do
          sleep 1
        done
        cp logo-144.png /var/lib/tomcat9/webapps/guacamole/images/
        cp logo-64.png /var/lib/tomcat9/webapps/guacamole/images/
        cp logo-144.png /var/lib/tomcat9/webapps/guacamole/images/guac-tricolor.png
        sed -i "s/Apache Guacamole/Aviatrix Build - ${pod_id}/g" /var/lib/tomcat9/webapps/guacamole/translations/en.json
        systemctl restart tomcat9
        systemctl restart guacd

        # whoami
        # ls -l /var/lib/
        # ls -l /var/lib/tomcat9/
        # ls -l /var/lib/tomcat9/webapps/
        # ls -l /var/lib/tomcat9/webapps/guacamole/
        # ls -l /var/lib/tomcat9/webapps/guacamole/images/
        # cp logo-144.png /var/lib/tomcat9/webapps/guacamole/images/
        # cp logo-64.png /var/lib/tomcat9/webapps/guacamole/images/
        # cp logo-144.png /var/lib/tomcat9/webapps/guacamole/images/guac-tricolor.png
        # sed -i "s/Apache Guacamole/Aviatrix Build - ${pod_id}/g" /var/lib/tomcat9/webapps/guacamole/translations/en.json
             
runcmd:
  - bash /root/test.sh