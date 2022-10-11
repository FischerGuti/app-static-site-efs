#!/bin/bash
yum update -y
yum install -y amazon-efs-utils
wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
/usr/bin/python3 /tmp/get-pip.py
/usr/local/bin/pip3 install botocore
mkdir /mnt/efs
echo "${efs_id}:/ /mnt/efs efs _netdev,noresvport,tls 0 0" >> /etc/fstab
x=9
while (( $x > 0 )); do
  mount -fav
  mnt=`df -h |grep /mnt/efs |wc -l`
  if (( $mnt >= 1 )); then break; fi
  echo $((x--))
  sleep 10
done

yum install -y httpd git
systemctl enable httpd
cd /tmp
git clone https://github.com/kledsonhugo/app-static-site-efs
mkdir /mnt/efs/html
cp /tmp/app-static-site-efs/app/*.html /mnt/efs/html
rm -rf /var/www/html/
ln -s /mnt/efs/html/ /var/www/html
service httpd restart