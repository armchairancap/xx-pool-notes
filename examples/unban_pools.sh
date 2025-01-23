#!/bin/bash

# This script will unban all pool members that have been banned by UFW
# https://github.com/armchairancap/xx-pool-notes
# (c) 2025 ArmchairAncap
# License: Apache 2.0

# backup /etc/ufw/ into a timestamped tar file
timestamp=$(date +%Y%m%d%H%M%S)
sudo tar -czvf $HOME/ufw_rules_$timestamp.tar.gz /etc/ufw/
# to restore, stop `ufw` service, restore, and start `ufw` service
# sudo ufw disable; tar xzvf ufw.tar.gz; cd ./etc; sudo rsync -avf ufw /etc/; 
# sudo chown -R root:root /etc/ufw; sudo ufw enable

# Rules created by us have "blocked pool member" in the comment
rules=$(sudo ufw status numbered | grep "DENY IN" | grep "# blocked pool member")

rule_numbers=($(echo "$rules" | grep -oP '\[\s*\d+\]' | grep -oP '\d+'))
# Delete such rules
for i in $(seq $((${#rule_numbers[@]} - 1)) -1 0); do
    rule_number=${rule_numbers[$i]}
    echo "y" | sudo ufw delete $rule_number
done

exit 0

----
$ sudo ufw status numbered
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] Anywhere                   DENY IN     2.2.2.2                    # blocked pool member
[ 2] Anywhere                   DENY IN     3.3.3.3                    # blocked pool member
[ 5] 22/tcp                     ALLOW IN    10.0.0.0/8                 # SSH access


