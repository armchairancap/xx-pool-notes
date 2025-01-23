#!/usr/bin/env bash

# This script will ban pool members from pool_list.txt using UFW
# https://github.com/armchairancap/xx-pool-notes
# (c) 2025 ArmchairAncap
# License: Apache 2.0

while IFS= read -r block
do 
   sudo ufw insert 1 deny from "$block" comment "blocked pool member"
done < "pool_list.txt"


