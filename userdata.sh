#!/bin/bash
#---------------------------------------------------
# User Data Script to Install and Start NGINX on Ubuntu
#---------------------------------------------------

# Update system packages
apt-get update -y

# Install NGINX
apt-get install -y nginx

# Enable and start the NGINX service
systemctl enable nginx
systemctl start nginx

# Create a simple HTML page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
<title>Terraform Sever</title>
</head>
<body>

<h1>This is a Server-1</h1>
<p>Terraform Infrastructure.</p>

</body>
</html>
