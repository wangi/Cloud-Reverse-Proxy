# Cloud Reverse Proxy
Cloud Reverse Proxy enables applications to be exposed to the internet without the need for public IP addresses or opening ports on a firewall.

This project configures a Reverse Proxy-over-VPN (RPoVPN) and is ideal for those:
- Self-hosting behind double-NAT or via an ISP that does CGNAT (Starlink, Mobile Internet).
- Unable to port forward on their local network due to insufficient access.
- With a dynamically allocated IP that may change frequently.

It derives from [N-Quan/Cloud-Reverse-Proxy](https://github.com/N-Quan/Cloud-Reverse-Proxy), [NGINX: Installing Proxy Manager in LXC — V2, Debian](https://medium.com/@rar1871/nginx-installing-proxy-manager-in-lxc-v2-debian-d4d4c98109b1) and [ej52/proxmox-scripts](https://github.com/ej52/proxmox-scripts). Always review shell scripts before executing them on your system.

# Getting Started
## Prerequisites
- Create domain name with record pointing to the Cloud Server's public ip.
- A cloud server running Ubuntu 24.04 (AWS, Linode, Digital Ocean, etc..) with the following requirements:
    - Open TCP ports 80/443 (http(s)) and UDP port 55107
- A system on your local network - baremetal, VM, container, whatever (e.g. Proxmox LXC container running Ubuntu 24.04, with 2 CPU, 1GB RAM, 512 swap, 8GB primary disk)

## Steps
### 1. Cloud Installer
Run this script on the Cloud Server and follow prompts
```
curl -s -o cloud_installer.sh https://raw.githubusercontent.com/wangi/Cloud-Reverse-Proxy/main/cloud_installer.sh
chmod +x cloud_installer.sh
sudo ./cloud_installer.sh
```

### 2. Local Installer
Setup Nginx Proxy Manager on the local machine. Then run this script and follow prompts.
```
curl -s -o local_installer.sh https://raw.githubusercontent.com/wangi/Cloud-Reverse-Proxy/main/local_installer.sh
chmod +x local_installer.sh
sudo ./local_installer.sh
```

### 3. Setup Nginx Proxy Manager (NPM)
Follow the URL provided by the Local Installer to configure NPM. You can also add a Streams configuration to forward port 2222 to SSH port 22 on a local bastion / jump SSH server.

# Network Topology
## Cloud Server
Your domain sends http(s) traffic to the Cloud Server running WireGuard. The http(s) traffic gets forwarded to the Proxmox container in your home network via the WireGuard tunnel. Port 2222 is also forwarded, intended to be used as custom SSH port.

## Container running reverse proxy
Receives tunneled http(s) traffic which hits Nginx Proxy Manager (NPM).
NPM can point to any service running in the home network. Hosted services can be running on the same or different machine.
