#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root using sudo."
    exit 1
fi

#The following cURL cmommand will install the file browser in your machine.
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

#Add the the custom configuration to the system.
cat << EOF > /etc/filebrowser.json
{
  "port": 8080,
  "baseURL": "",
  "address": "0.0.0.0",
  "log": "stdout",
  "database": "/etc/database.db",
  "root": "/"
}
EOF

#Create the daemon service file for filebrowser.
cat << EOF > /etc/systemd/system/filebrowser.service
[Unit]
Description=File Browser
After=network.target

[Service]
ExecStart=/usr/local/bin/filebrowser -c /etc/filebrowser.json

[Install]
WantedBy=multi-user.target
EOF

#Create symlLink and start the daemon service for filebrowser.
systemctl enable filebrowser.service
systemctl start filebrowser.service

echo -e "The application will be running in Port: 8080\n\nLogin credentials:\nUsername : admin\nPassword : admin"