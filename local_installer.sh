############################################## WIREGUARD ##############################################
# Install WireGuard
sudo apt update -y
sudo apt install wireguard -y

# Generate keys
(umask 077 && printf "[Interface]\nPrivateKey= " | sudo tee /etc/wireguard/wg0.conf > /dev/null) 
wg genkey | sudo tee -a /etc/wireguard/wg0.conf | wg pubkey | sudo tee /etc/wireguard/publickey

# Get VPS public IP
echo "Enter the public IP of your VPS/ Cloud Server:" 
read -r vps_public_ip </dev/tty

# Get VPS public key
echo "Enter the public key from your VPS/ Cloud Server:" 
read -r vps_pubkey </dev/tty

# Wireguard Config
echo "Address = 192.168.4.2 
[Peer] 
PublicKey = $vps_pubkey 
AllowedIPs = 0.0.0.0/0 
Endpoint = $vps_public_ip:55107 
PersistentKeepalive = 25 " | sudo tee -a /etc/wireguard/wg0.conf >/dev/null

# Start Wireguard
sudo systemctl start wg-quick@wg0 
sudo systemctl enable wg-quick@wg0

echo "Wireguard Successfully Configured!"
echo "Local Machine public key is:"
sudo cat /etc/wireguard/publickey

######################################### NGINX PROXY MANAGER #########################################
# Install Nginx Proxy Manager using script from https://github.com/ej52/proxmox-scripts/tree/main/apps/nginx-proxy-manager
# per write up at https://medium.com/@rar1871/nginx-installing-proxy-manager-in-lxc-v2-debian-d4d4c98109b1
sh -c "$(wget --no-cache -qO- https://raw.githubusercontent.com/ej52/proxmox/main/install.sh)" -s --app nginx-proxy-manager

echo "Local Machine public key is:"
sudo cat /etc/wireguard/publickey
echo "Setup Nginx Proxy Manager at $(hostname -I | awk '{print $1}'):81 to start hosting your services to the web!"
