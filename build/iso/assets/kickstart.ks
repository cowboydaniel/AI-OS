# Kickstart for Mint-based remastering used by casper/oem-config flows.
lang en_US.UTF-8
keyboard us
timezone UTC --utc
network --bootproto=dhcp --hostname=aetheros
rootpw --iscrypted $6$QVrTnTLsuegDiPNq$JpBfQAGDP7P0h5nJiBv1q3flfOHd.AjEUbigt9tQQ07KDssEx7hpY9p3NEeX54ZaoQWeJF2/YoYY6cOsG36ED1
user --name=aether --fullname="AetherOS User" --iscrypted --password=$6$QVrTnTLsuegDiPNq$JpBfQAGDP7P0h5nJiBv1q3flfOHd.AjEUbigt9tQQ07KDssEx7hpY9p3NEeX54ZaoQWeJF2/YoYY6cOsG36ED1
firewall --enabled
selinux --permissive
auth --enableshadow --passalgo=sha512
services --enabled=NetworkManager,sshd

autopart --type=lvm
bootloader --location=mbr --timeout=5
reboot

%packages
@mint-meta-core
openssh-server
curl
%end

%post --log=/root/aetheros-branding.log --erroronfail
mkdir -p /aetheros/branding
cp -r /cdrom/aetheros/branding-hooks /aetheros/branding
chmod +x /aetheros/branding/apply-branding.sh
/aetheros/branding/apply-branding.sh
%end
