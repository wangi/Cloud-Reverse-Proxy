# Install WireGuard
sudo apt update -y
sudo apt install wireguard -y

# Generate keys
(umask 077 && printf "[Interface]\nPrivateKey= " | sudo tee /etc/wireguard/wg0.conf > /dev/null) 
wg genkey | sudo tee -a /etc/wireguard/wg0.conf | wg pubkey | sudo tee /etc/wireguard/publickey

# Get home server public key
echo "Enter the public key from your home server/ local machine:" 
read -r home_server_pubkey </dev/tty

# Wireguard Config
echo "ListenPort = 55107 
Address = 192.168.4.1 

# firewall allow
PostUp = iptables -P FORWARD DROP
PostUp = iptables -A FORWARD -i eth0 -o wg0 -p tcp --syn -m multiport --dports 80,443,9022 -m conntrack --ctstate NEW -j ACCEPT
PostUp = iptables -A FORWARD -i eth0 -o wg0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
PostUp = iptables -A FORWARD -i wg0 -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
PostUp = iptables -A FORWARD -i wg0 -o eth0 -p tcp -m multiport --dports 80,443 -j ACCEPT
PostDown = iptables -P FORWARD ACCEPT
PostDown = iptables -D FORWARD -i eth0 -o wg0 -p tcp --syn -m multiport --dports 80,443,9022 -m conntrack --ctstate NEW -j ACCEPT
PostDown = iptables -D FORWARD -i eth0 -o wg0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
PostDown = iptables -D FORWARD -i wg0 -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
PostDown = iptables -D FORWARD -i wg0 -o eth0 -p tcp -m multiport --dports 80,443 -j ACCEPT

# port forwarding
PreUp = iptables -t nat -A PREROUTING -i eth0 -p tcp -m multiport --dports 80,443,9022 -j DNAT --to-destination 192.168.4.2
PostDown = iptables -t nat -D PREROUTING -i eth0 -p tcp -m multiport --dports 80,443,9022 -j DNAT --to-destination 192.168.4.2

# masquerade outbound packets
PreUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer] 
PublicKey = $home_server_pubkey
AllowedIPs = 192.168.4.2/32 
" | sudo tee -a /etc/wireguard/wg0.conf >/dev/null

# Allow IPv4 forwarding
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.conf >/dev/null

# Apply changes
sudo sysctl -p 
sudo sysctl --system

# Start Wireguard
sudo systemctl start wg-quick@wg0 
sudo systemctl enable wg-quick@wg0

clear
echo "Cloud Server public key is:"
sudo cat /etc/wireguard/publickey
echo "Wireguard Successfully Configured!"
