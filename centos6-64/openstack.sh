#yum install cloud-init acpid curl -y
#chkconfig cloud-init on
yum install acpid curl sudo -y
chkconfig acpid on
service acpid start

cat >> /etc/rc.local << EORCLOCAL
#
# OpenStack
#
depmod -a
modprobe acpiphp

touch /var/lock/subsys/local
if [ ! -d /root/.ssh ]; then
  mkdir -p /root/.ssh
  chmod 700 /root/.ssh
fi
 
# Fetch public key using HTTP
ATTEMPTS=30
FAILED=0
while [ ! -f /root/.ssh/authorized_keys ]; do
  curl -f http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key > /tmp/metadata-key 2>/dev/null
  if [ $? -eq 0 ]; then
    cat /tmp/metadata-key >> /root/.ssh/authorized_keys
    chmod 0600 /root/.ssh/authorized_keys
    restorecon /root/.ssh/authorized_keys
    rm -f /tmp/metadata-key
    echo "Successfully retrieved public key from instance metadata"
    echo "*****************"
    echo "AUTHORIZED KEYS"
    echo "*****************"
    cat /root/.ssh/authorized_keys
    echo "*****************"

    curl -f http://169.254.169.254/latest/meta-data/hostname > /tmp/metadata-hostname 2>/dev/null
    if [ $? -eq 0 ]; then
      TEMP_HOST=$(cat /tmp/metadata-hostname)
      sed -i "s/^HOSTNAME=.*$/HOSTNAME=$TEMP_HOST/g" /etc/sysconfig/network
      /bin/hostname $TEMP_HOST
      echo "Successfully retrieved hostname from instance metadata"
      echo "*****************"
      echo "HOSTNAME CONFIG"
      echo "*****************"
      cat /etc/sysconfig/network
      echo "*****************"

    else
      echo "Failed to retrieve hostname from instance metadata.  This is a soft error so we'll continue"
    fi
    rm -f /tmp/metadata-hostname
  else
    FAILED=$(($FAILED + 1))
    if [ $FAILED -ge $ATTEMPTS ]; then
      echo "Failed to retrieve public key from instance metadata after $FAILED attempts, quitting"
      break
    fi
      echo "Could not retrieve public key from instance metadata (attempt #$FAILED/$ATTEMPTS), retrying in 5 seconds..."
      sleep 5
    fi
done
#
# End OpenStack
#
EORCLOCAL

cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOETH0
DEVICE="eth0"
BOOTPROTO=dhcp
NM_CONTROLLED="yes"
ONBOOT="yes"
EOETH0

# Not sure if this is necessary...??? XXX
cat > /etc/udev/rules.d/70-persistent-net.rules << EOPERS
ACTION=="add",SUBSYSTEM=="net", IMPORT{program}="/lib/udev/rename_device" SUBSYSTEM=="net", RUN+="/etc/sysconfig/network-scripts/net.hotplug"
EOPERS

# This is kind of ugly...
sed -i 's|rd_NO_LUKS|rd_NO_LUKS console=tty0 console=ttyS0,115200|' /boot/grub/grub.conf 
 