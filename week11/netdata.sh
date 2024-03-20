wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh --no-updates
systemctl status netdata
sudo systemctl start netdata
sudo systemctl enable netdata
apt install net-tools
netstat -tpuln


sudo su
apt install nginx
cd /var/www/html/
dd if=/dev/zero of=file.bin bs=1M count=10240

