cat /etc/systemd/system/hr.service
ini
￼
Copy
￼
Download
[Unit]
Description=HR Go API Server
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/go/hr
ExecStart=/var/www/go/hr/api-server
Restart=always
RestartSec=10
Environment=DB_HOST=localhost
Environment=DB_PORT=3306
Environment=DB_USER=flutter_user
Environment=DB_PASSWORD=your_password
Environment=DB_NAME=flutter_app
Environment=JWT_SECRET=your-super-secret-key

[Install]
WantedBy=multi-user.target