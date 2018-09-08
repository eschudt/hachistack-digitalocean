#! /bin/bash

echo "Installing Consul on server\n"

# Install required packages
apt-get update
apt install --yes unzip
apt install --yes docker.io

# Setup iptables to allow access to localhost from docker
sysctl -w net.ipv4.conf.docker0.route_localnet=1
iptables -t nat -I PREROUTING -i docker0 -d 172.17.0.1 -p tcp --dport 8500 -j DNAT --to 127.0.0.1:8500
iptables -t filter -I INPUT -i docker0 -d 127.0.0.1 -p tcp --dport 8500 -j ACCEPT

# Start install of consul and setup 
wget https://releases.hashicorp.com/consul/1.2.1/consul_1.2.1_linux_amd64.zip
unzip consul_1.2.1_linux_amd64.zip
cp consul /usr/bin/
mkdir /etc/consul.d
mkdir /tmp/consul

# Start consul as a service
if [ $1 == "server" ]; then
	systemctl enable consul-server.service
	systemctl start consul-server.service
else
	systemctl enable consul-client.service
	systemctl start consul-client.service
  	sleep 5
	consul join $3
fi
echo "Installation of Consul complete\n"
exit 0
