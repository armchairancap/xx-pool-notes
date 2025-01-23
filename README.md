- [xx-pool-notes](#xx-pool-notes)
- [Methodology](#methodology)
  - [Self-identified pools](#self-identified-pools)
  - [Less obvious](#less-obvious)
- [Blocking approach](#blocking-approach)
- [How to find a validator node's IP address](#how-to-find-a-validator-nodes-ip-address)
- [Using `ufw` to block pool nodes](#using-ufw-to-block-pool-nodes)
  - [Unblock blocked IPs](#unblock-blocked-ips)
- [Automation](#automation)
- [Blacklists, whitelists, graylists](#blacklists-whitelists-graylists)
- [Community contributions](#community-contributions)

## xx-pool-notes

These are notes on centralized validator pools on xx Network, mostly consisting of instructions of how to identify and block validator nodes that belong to centralized pools.

You may read about the problem below, but long story short these centralized pools weaken the security of xx Network's cMix as well as xx chain.

- [An attempt to address validator centralization problem](https://armchairancap.github.io/blog/2025/01/06/xx-network-armchairancap-pool)
- [First anti-pool pool node elected](https://armchairancap.github.io/blog/2025/01/23/xx-network-armchairancap-pool-elected)

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

### Self-identified pools

- MONEYTEAM
- CRYPTOCALIBUR
- UNITED EARTH

### Less obvious 

TBD (TODO: need to see if IP addresses may be published on Github).

## Blocking approach

xx Network stack officially supports Ubuntu. IP blocking with `ufw` works well because it creates pre-realtime failures. 

This approach doesn't hurt the network. Blocked pool members time-out and fail before they begin real-time rounds.

The other good pint is it doesn't let pools fail quickly either, which would allow them to move on to the next round where no peer is blocking their IP. 

## How to find a validator node's IP address

Let's take `MONEYTEAM 04` (on-chain ID of a validator) for an example. Use xx Network Wallet to find out more about it.

This node is currently controlled by wallet `6VzVErFXM3e9FE8uvSU7fwCpMuJW8j8HWMxz62kQwexvxjF6` which the xx Network Walle shows has the cMix ID of `jBRTuDxyR8q0hAIN6T24nyqK/cBMOhiITIAeLQpEF5YC`. 

Now go to your node, and `grep` the log for that cMix ID and you'l see this node's IP address or hostname.

The next step is to use `ufw` to block it.

## Using `ufw` to block pool nodes

We want to block them on the cMix server.

Store IP addresses in a list such as pool_list.txt:

```raw
2.2.2.2
3.3.3.3
```

If they use FQDNs, resolve those to IPv4 addresses first.

Then run this script:

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

You could run this on a regular basis, as existing rules are skipped.

```sh
$ sudo bash block.sh 
Skipping inserting existing rule
Skipping inserting existing rule
```

### Unblock blocked IPs

You can remove the rules like this:

```sh
sudo ufw status numbered
sudo ufw delete  1
sudo ufw delete  2
```

If you have many rules, you may use unban_pools.sh from the examples folder. It can delete 100+ rules in seconds.

## Automation

We could use scheduled jobs (cron or other) to get a pool IP blacklist from this repo and apply it. 

But the publishing of IPs may not be allowed in some jurisdictions so for now only the methodology will be published as it is done above.

It should be fine to publish cMix IDs which you could convert to IPv4 addresses on your own, so this will be considered.

Another promising approach would be with fail2ban, for which we could define custom actions (e.g. ban for a day). Then the blacklist could be pulled daily and any nodes that get *removed* from it, would be automatically removed by fail2ban within 24 hours. Depending on interest, these instructions may be created at a later time.

## Blacklists, whitelists, graylists

cMix IDs of large pool members are published in a blacklist. 

A graylist with suspicious validators may be published as well. It could be used by ethical nominators as an "avoid list" when nominating.

Depending on interest, a whitelist may be created as well. The purpose of a whitelist would be to validate self-produced blacklists to potentially avoid blocking good nodes. This would be advisory, obviously, and could be added to a script to warn or drop blocking IDs from the blacklist. We could also use it to encourage nominators to nominate 

## Community contributions

Contributions are welcome. Please create a pull request to update cMix ID blacklist or whitelist, or submit an issue with suspected cMix ID and indications of the problems it has.

You can also contribute by *nominating* my pool or validators that block centralized pools or contribute here.
