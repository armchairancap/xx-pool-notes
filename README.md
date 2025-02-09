- [xx-pool-notes](#xx-pool-notes)
- [Methodology](#methodology)
  - [Self-identified pools](#self-identified-pools)
  - [Non-obvious pools](#non-obvious-pools)
- [Blocking approach](#blocking-approach)
- [How to find a validator node's IP address](#how-to-find-a-validator-nodes-ip-address)
- [Using `ufw` to block pool nodes](#using-ufw-to-block-pool-nodes)
- [Unblock blocked IPs](#unblock-blocked-ips)
- [Update blocked IPs](#update-blocked-ips)
- [Automation](#automation)
- [Monitoring](#monitoring)
- [Blacklists, whitelists, graylists](#blacklists-whitelists-graylists)
- [Privacy](#privacy)
- [Community contributions](#community-contributions)
- [Delegate voting and staking to `ARMCHAIRANCAP`](#delegate-voting-and-staking-to-armchairancap)

## xx-pool-notes

These are notes on (identifying and blocking) centralized validator pools on xx Network, mostly consisting of instructions of how to identify and block xx Network validator nodes that belong to large centralized pools (large means five or more validator stacks).

You may read about the problem below, but long story short these centralized pools weaken the security of xx Network's cMix as well as xx chain.

- [An attempt to address validator centralization problem](https://armchairancap.github.io/blog/2025/01/06/xx-network-armchairancap-pool)
- [First anti-pool pool node elected](https://armchairancap.github.io/blog/2025/01/23/xx-network-armchairancap-pool-elected)

To save time, you can simply nominate one one of `ARMCHAIRANCAP` nodes - I'll do the blocking for you.

If you're a validator you can continue reading and use this approach to block pools on your own. 
 
## Methodology

xx Network's cMixx mixnet currently uses groups of five nodes. Therefore, no operator should run more than four nodes.

How to find 'em? They usually have something in common. For now we can single out any group of five or more nodes that meets one or more of these criteria.

- Self-identified and obvious
  - On-chain identity (such as `MONEYTEAM`)
- Less obvious
  - shared IP address range (or single address)
  - on-chain information (e.g. shared Web site) indicates it's a pool
  - shared controller (wallet) 
  - on-chain transaction relationships among controlling wallets

This screenshot illustrates the latter case:

- Five nodes
- Same location
- Extremely high commission (fine in itself) indicates only the owner would nominate such nodes
 
![Less obvious pool](images/less-obvious-pool.png)

We can say this *likely* a single operator running a large pool. This is "gray area" to say the least. The operator could simply run four nodes and deploy the rest of their resources on some other chain, but they prefer to run five nodes here for own convenience. All right, then!

### Self-identified pools

This list may change and may not necessarily be updated when/if it does change. But at the time of writing, these are some of the more prominent centralized pools with more than four nodes:

- MONEYTEAM
  - Sample cMix ID: https://dashboard.xx.network/nodes/coA_NSJnzDh1pdPAkmWtPpNEvogM0isISv9SS0bs0R0C
- CRYPTOCALIBUR
  - Sample cMix ID: https://dashboard.xx.network/nodes/z6iiPShZLYn6wKy_kmMbFenQRoPZnBoKr3GzQXeKndkC
- UNITED EARTH
  - Sample cMix ID: https://dashboard.xx.network/nodes/UE_DIV4NVhpgLDsPdqoTl5Wyf3pI1RkvSgnGBfNNUdsC

### Non-obvious pools

This repo may publish cMix IDs of nodes believed to be controlled by one entity (operator or operators). See [Privacy](#privacy) for more information.

Taking the screenshot above as an example, these would be cMix IDs of the five nodes:

```
w6f3Hf07TwJlfK8XSQpXCCTK7SH7-GPwAXgtX7fgWMMC # https://dashboard.xx.network/nodes/w6f3Hf07TwJlfK8XSQpXCCTK7SH7-GPwAXgtX7fgWMMC
W-ZHoPZ85yTkX7kUge8F5_Es4P5I3edvIocmFHEKrxEC # https://dashboard.xx.network/nodes/W-ZHoPZ85yTkX7kUge8F5_Es4P5I3edvIocmFHEKrxEC
z1zssHc6Cyyp2azJZrEsxXBHNTnnz0Z9X8ib2RI9GPUC # https://dashboard.xx.network/nodes/z1zssHc6Cyyp2azJZrEsxXBHNTnnz0Z9X8ib2RI9GPUC
pSyg29YV6I6LlErWbVPYMq2UgzAr7c7-Mz8RZqTl-rAC # https://dashboard.xx.network/nodes/pSyg29YV6I6LlErWbVPYMq2UgzAr7c7-Mz8RZqTl-rAC
dPiLLh28uilU5cPmf5qU61rijOQL1F90rjGE4df8xVIC # https://dashboard.xx.network/nodes/dPiLLh28uilU5cPmf5qU61rijOQL1F90rjGE4df8xVIC 
```

## Blocking approach

xx Network stack officially supports Ubuntu. IP blocking with `ufw` works well because it creates pre-realtime failures. 

This approach doesn't hurt the network. Blocked pool members time-out and fail before they begin real-time rounds.

The other good pint is it doesn't let pools fail quickly either, which would allow them to move on to the next round where no peer is blocking their IP. 

## How to find a validator node's IP address

Let's take `MONEYTEAM 04` (on-chain ID of a validator) for an example. Use xx Network Wallet to find out more about it.

This node is currently controlled by wallet `6VzVErFXM3e9FE8uvSU7fwCpMuJW8j8HWMxz62kQwexvxjF6` which the xx Network Walle shows has the cMix ID of `jBRTuDxyR8q0hAIN6T24nyqK/cBMOhiITIAeLQpEF5YC`. 

Now go to your node, and `grep` the log for that cMix ID and you'l see this node's IP address or hostname. Using the last of the five cMix IDs above (dPiLLh28uilU5cPmf5qU61rijOQL1F90rjGE4df8xVIC):

```sh
$ cat /opt/xxnetwork/log/cmix.log | grep dPiLLh28uilU5cPmf5qU61rijOQL1F90rjGE4df8xVIC | grep "at " | awk '{print $8}' | cut -f 1 -d ":"
81.7.xxx.xxx
```

The next step is to use `ufw` to block that IP address.

## Using `ufw` to block pool nodes

We want to block their cMix server ("node") on our cMix server.

Store their IPv4 addresses in a list such as pool_list.txt:

```raw
2.2.2.2
3.3.3.3
```

If their cMix node uses FQDN (Dynamic DNS, for example), resolve those to IPv4 addresses first.

Then run this script (which, by the way, requires that `ufw` be enabled and at least one rule - such as to allow SSH - to exist, which is the default in xx Network Handbook):

```sh
#!/usr/bin/env bash

while IFS= read -r block
do 
   sudo ufw insert 1 deny from "$block" comment "blocked pool member"
done < "pool_list.txt"
```

Appreciate your work:

```sh
$ sudo ufw status numbered
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] Anywhere                   DENY IN     2.2.2.2                    # blocked pool member
[ 2] Anywhere                   DENY IN     3.3.3.3                    # blocked pool member
[ 5] 22/tcp                     ALLOW IN    10.0.0.0/8                 # SSH access
```

You can now watch with `sudo tail -f /var/log/syslog` and should see those IPs blocked (when they get scheduled to run in rounds with your node).

You could run this on a regular basis without "editing" rules, because `ufw` automatically skips duplicate rules.

```sh
$ sudo bash block.sh 
Skipping inserting existing rule
Skipping inserting existing rule
```

## Unblock blocked IPs

You can remove the rules like this:

```sh
sudo ufw status numbered
sudo ufw delete  1
sudo ufw delete  2
```

If you have many rules, you may use unban_pools.sh from the examples folder. It can delete 100+ rules in seconds.

If you want to delete only *some* of the nodes from the list:
- make a copy of the list
- unblock all nodes (using the original list)
- then edit the copy of the list (remove certain nodes), copy it over the original list and block the nodes from the list

## Update blocked IPs

- Using **current** pool IP list, run unblock script to unblock the entire list
- Make a copy of the list. Update list with new IP(s) and run block script on the list

If you want to add block just one address manually, just use the command from the block script:

```sh
sudo ufw insert 1 deny from xxx.xxx.xxx.xxx comment "blocked pool member"
```

It's better to use pool_list.txt, though, because it's easier to keep track of addresses: `cat pool_list.txt | grep A.B.C.D` or `ufw status numbered | grep A.B.C.D` tells you if the address (`A.B.C.D`) is already blocked. If not, just update the list and re-apply with the script.

## Automation

We could use scheduled jobs (cron or other) to get a pool IP blacklist from this repo and apply it. 

But the publishing of IPs may not be allowed in some jurisdictions, so for now only the methodology will be published as per above.

It should be fine to publish cMix IDs which you could convert to IPv4 addresses on your own (using cmix.log data).

Another promising approach would be with fail2ban, for which we could define custom actions (e.g. ban for a day). Then the blacklist could be pulled daily and any nodes that get *removed* from it would be automatically removed by fail2ban within 24 hours. Depending on interest, these instructions may be created at a later time.

## Monitoring

To confirm rounds are failing as expected, do another grep command on cmix.log to make sure rounds with blocked, and only with blocked, nodes are failing as expected.

With a list that has 10 or more IP addresses, your node would earn less. Cut the list to a manageable size (e.g. pick just `MONEYTEAM`) if you cannot tolerate lower earnings.

## Blacklists, whitelists, graylists

cMix IDs of large pool members are published in a blacklist.

A graylist with suspicious validators may be published as well. It could be used by ethical nominators as an "avoid list" when nominating ("staking") node operators.

Depending on interest, a whitelist may be created as well. The purpose of a whitelist would be to validate self-produced blacklists to potentially avoid blocking good nodes. This would be advisory, obviously, and could be added to a script to warn or drop blocking IDs from the blacklist. We can also use it to encourage nominators to nominate ethical, privacy-respecting validators.

## Privacy

According to [this](https://law.stackexchange.com/questions/41540/is-a-public-ip-address-classified-as-personal-data-for-a-third-party-under-eu), IP addresses, even dynamic ones, are considered Personal Data (PD) in some jurisdictions:

> While the case law is scanty on the point, it appears that the consensus is that IP addresses, even dynamic IP addresses, will be considered to be Personal Data under the GDPR.

There are arguments (in the comments) that point out that addresses that do not belong to natural persons aren't PD. But in our case they would be for anyone running cMix at home from an address shared by natural persons. I will therefore **not** publish IP addresses in this repository. 

But cMix IDs are not Personal Data. They would be *if* the operators were to identify themselves, so for time being, cMix IDs will be listed *unless* the wallet has on-chain identity clearly identifying natural person at the time of listing. Pull requests to *remove* cMIx IDs of node operators who provide PD in on-chain identity after the fact will be accommodated. Because of the nature of such removal, this repository's history may need to be removed after each request.

Note that nodes who belong to operators with self-published on-chain identity will be easily identifiable, so requesting a removal of a cMix ID due to an on-chain identity with personal data would simply make it clear such nodes *are* in fact operated by a large pool operator and therefore easy to identify from on-chain data and without this repo publishing anything about the node or its operator.

## Community contributions

Contributions are welcome. Please create a pull request to update cMix ID blacklist or whitelist, or submit an issue with suspected cMix ID and share your concerns.

You can also contribute by *nominating* my pool or validators that block centralized pools or contribute here.

## Delegate voting and staking to `ARMCHAIRANCAP`

If you'd like to leave your staking management to me, you may delegate it to me like so.


