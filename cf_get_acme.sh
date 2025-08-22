#!/bin/sh
VER=1.1.0

# Configuration
DOMAIN="drive.zend.eu.org"
CERT_DIR="/etc/webdav-server/ssl/zend.eu.org"
INSTALL_DIR="/etc/webdav-server/ssl"
ACME_SH="/root/.acme.sh/acme.sh"  # Replace with actual path or ensure acme.sh is in PATH
SERVICE_NAME="webdav-server"

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Ensure acme.sh exists
[ -x "$ACME_SH" ] || handle_error "acme.sh not found at $ACME_SH"

# Create certificate directories
mkdir -p "$CERT_DIR" "$INSTALL_DIR" || handle_error "Failed to create directories"

# Issue certificate
"$ACME_SH" --issue -d "$DOMAIN" --dns dns_cf --certhome "$CERT_DIR" --ca-path /etc/ssl/certs || handle_error "Certificate issuance failed"

# Install certificate
"$ACME_SH" --install-cert -d "$DOMAIN" --certhome "$CERT_DIR" \
    --keypath "$INSTALL_DIR/tls.key" --fullchain-file "$INSTALL_DIR/tls.crt" || handle_error "Certificate installation failed"

# Convert private key to PKCS#8 format
openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt \
    -in "$INSTALL_DIR/tls.key" -out "$INSTALL_DIR/tls.key.pkcs8" || handle_error "Private key conversion failed"

# Backup original key and replace with PKCS#8 version
mv "$INSTALL_DIR/tls.key" "$INSTALL_DIR/tls.key.bak" || handle_error "Failed to backup original key"
mv "$INSTALL_DIR/tls.key.pkcs8" "$INSTALL_DIR/tls.key" || handle_error "Failed to replace key with PKCS#8 version"

# Set permissions and ownership
chmod 600 "$INSTALL_DIR/tls.key" || handle_error "Failed to set key permissions"
chown root:root "$INSTALL_DIR/tls.key" || handle_error "Failed to set key ownership"

# Restart WebDAV server
systemctl restart "$SERVICE_NAME" || handle_error "Failed to restart $SERVICE_NAME"

echo "Certificate successfully installed and $SERVICE_NAME restarted"
