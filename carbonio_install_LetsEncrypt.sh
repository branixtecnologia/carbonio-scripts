#!/bin/bash
#https://community.zextras.com/forum/carbonio-setup/carbonio-ce-related-scripts/paged/2/#post-8090

# Check if the script is run as zextras
if [ "$(whoami)" != "zextras" ]; then
  echo "This script must be run as the zextras user."
  exit 1
fi

echo "Starting Let's Encrypt SSL installation script."

# Setting zimbraVirtualHostName for each domain as zextras user
for i in $(carbonio prov -l gad); do 
  carbonio prov md $i zimbraVirtualHostName mail.$i
  echo "Virtual Hostname set for domain $i"
done
echo "Virtual Hostnames set for all domains."

sleep 1

# Setting zimbraReverseProxyMailMode to redirect as zextras user
carbonio prov ms $(hostname -f) zimbraReverseProxyMailMode redirect
echo "zimbraReverseProxyMailMode set to redirect."

sleep 1

# Restarting zmproxyctl as zextras user
zmproxyctl restart
echo "zmproxyctl restarted."

sleep 1

# Obtaining certificates for each domain as zextras user
for i in $(carbonio prov -l gad); do 
  /opt/zextras/libexec/certbot certonly --preferred-chain "ISRG Root X1" --agree-tos --email zextras@$(hostname -d) -n --keep --webroot -w /opt/zextras --cert-name $i -d mail.$i
  echo "Certificate obtained for domain $i"
done
echo "Certificates obtained for all domains."

sleep 1

# Restarting zmproxyctl again after obtaining certificates as zextras user
zmproxyctl restart
echo "zmproxyctl restarted after obtaining certificates."

echo "Let's Encrypt SSL installation script completed."

echo "##############################################################"
echo "#                                                            #"
echo "# WARNING: To set up auto-renewal for all domains, please    #"
echo "# execute the following commands as root:                    #"
echo "#                                                            #"
echo "#   sudo systemctl start carbonio-certbot.timer              #"
echo "#   sudo systemctl enable carbonio-certbot.timer             #"
echo "#                                                            #"
echo "##############################################################"
