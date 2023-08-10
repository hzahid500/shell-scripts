#!/bin/bash

# Update packages
sudo apt-get update -y

# install necessary packages
sudo apt-get install -y nginx

# configure Nginx
sudo cp /vagrant/nginx/conf /etc/nginx/nginx.conf

# restart nginx
sudo systemctl restart nginx

# install java runtime
sudo apt-get install -y default-jre

# installing jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins

sudo systemctl start jenkins

sudo systemctl enable jenkins

# installing docker
sudo apt update -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo systemctl status docker
sudo usermod -aG docker vagrant

# upgrading the packages 
sudo apt-get upgrade -y

# Disable unnecessary services
services=(
    avahi-daemon
    bluetooth
    cups
    isc-dhcp-server
    nfs-common
    rpcbind
    xinetd
)

for service in "${services[@]}"; do
    systemctl stop "$service"
    systemctl disable "$service"
done

# Disable unnecessary cron jobs
cron_jobs=(
    popularity-contest
    anacron
)

for cron_job in "${cron_jobs[@]}"; do
    rm -f "/etc/cron.daily/$cron_job"
    rm -f "/etc/cron.weekly/$cron_job"
    rm -f "/etc/cron.monthly/$cron_job"
    rm -f "/etc/cron.d/$cron_job"
done

# Remove unnecessary packages
packages=(
    telnet
    rsh-client
    rsh-server
    ypserv
    tftp
    talk
    finger
    whoopsie
    xinetd
)

apt-get purge -y "${packages[@]}"

# Disable unnecessary network protocols
echo "net.ipv4.icmp_echo_ignore_all=1" >> /etc/sysctl.conf
echo "net.ipv4.icmp_ignore_bogus_error_responses=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=1" >> /etc/sysctl.conf

sysctl -p

# Set file permissions
chmod 700 /etc/cron.deny
chmod 700 /etc/at.deny
chmod 700 /etc/xinetd.d

# Update the system
apt-get update && apt-get upgrade -y

# Installing ansible on nodes 
sudo apt-get install ansible -y

# Updating the system again
apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y

