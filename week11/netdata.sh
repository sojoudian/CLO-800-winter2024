wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh --no-updates
systemctl status netdata
sudo systemctl start netdata
sudo systemctl enable netdata
apt install net-tools
netstat -tpuln


sudo su
apt install nginx
dd if=/dev/zero of=/path/to/your/10GBfile.bin bs=1G count=10

