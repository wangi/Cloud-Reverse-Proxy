# IP Tables Explanation

See also https://www.procustodibus.com/blog/2022/09/wireguard-port-forward-from-internet/

## Forward traffic from eth0 to wg0 on specified ports
- These rules perform Destination Network Address Translation (DNAT). Traffic on ports 80, 443 and 9022 arriving at eth0 is forwarded to the internal IP address 192.168.4.2. 
- It's used to redirect incoming connections to a specific internal machine or service. 
```
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp -m multiport --dports 80,443,9022 -j DNAT --to-destination 192.168.4.2
```

## Masquerade
- Masquerade connections outbound to the Internet
- These rules won’t affect inbound connections that use port forwarding to reach to the private server; they will only affect outbound connections that are initiated by the private server itself (such as to download system updates, make DNS queries, etc).
```
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```
