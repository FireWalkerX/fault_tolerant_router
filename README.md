# Fault Tolerant Router

Fault Tolerant Router is a daemon, running in background on a Linux router or firewall, monitoring the state of multiple internet uplinks/providers and changing the routing accordingly. Outgoing connections are spread through the uplinks in a load balancing fashion via Linux multipath routing. Fault Tolerant Router monitors the state of the uplinks by routinely pinging well known IP addresses (for example Google public DNS servers) through each outgoing interface. Once an uplink goes down, it is excluded from the multipath routing. When it comes back up, it is included again. All of the routing changes are notified to the administrator by email.

Fault Tolerant Router is well tested and has been used in production for several years, in several sites.

## How it works
The system if based on the interaction of Linux multipath routing, iptables and ip policy routing. The system differentiates between outgoing connection and incoming connections.
  Outgoing connections (from LAN/DMZ to WAN):
  The first packet of an outgoing connection is sent through any one of the uplink interfaces, in round-robin fashion, letting the Linux multipath routing decide which one. The connection is marked with the outgoing interface using iptables, so that all subsequent packets of that connection and related ones are sent through the same interface (otherwise servers you connect to would see packets coming from different IP addresses and nothing would work).
  Incoming connections (from WAN to LAN/DMZ):
  When there is a new incoming connection, the connection is marked with the incoming interface using iptables, so that all subsequent return packets (sent from out LAN/DMZ to WAN) will be sent through the same uplink.

This is obtained by having a default multipath routing table for new outgoing connections and a specific routing table for each uplink for already established outgoing connections and for incoming ones.

Routes are cached.

## Uplink monitor algorithm

The daemon monitors the state of the uplinks by pinging well known IP addresses through each uplink: if enough pings are successful (see configuration options) the uplink is considered up, if not it's considered down. If a state change is detected from the previous check, the default multipath routing table (used for outgoing connections) is changed accordingly and the administrator is notified by email.

NB: if no uplink seems to be functional, all of them are added to the default multipath routing table
NB: it's important not to be very strict because it could happen that some ping packets get randomly lost along the way, ore some IPs may be down
NB: it's important to ping ip addresses far away because it happened to me personally that a provider had some routing temporary problems.

perché si usa rp_filter?


## Requirements

[Ruby](https://www.ruby-lang.org)
Linux kernel requirements

## Installation
    $ gem install fault_tolerant_router
_NB: gem not yet published, want to have a better documentation first_

## Usage

1. Configure your router interfaces as usual but **don't** set any default route.

2. Save an example configuration file in /etc/fault_tolerant_router.conf (use the --config option to set another location):
`$ fault_tolerant_router generate_config`

3. Edit /etc/fault_tolerant_router.conf

4. _(Optional)_ Demo how the daemon works, useful if it's the first time you see it:
`$ fault_tolerant_router --demo monitor`

5. Generate iptables rules and integrate them with your existing ones:
`$ fault_tolerant_router generate_iptables`

6. _(Optional)_ Test email notification, to be sure SMTP parameters are correct and the administrator will get notifications:
`$ fault_tolerant_router email_test`

7. Run the daemon:
`$ fault_tolerant_router monitor`  
Previous command will actually run Fault Tolerant Router in foreground. To run it in background you should use your Linux distribution specific method to start it as a system service. See for example [start-stop-daemon](http://manned.org/start-stop-daemon).
If you want a quick and dirty way to run the program in background, just add an ampersand at the end of the command line:  
`$ fault_tolerant_router monitor &`

## Configuration file
The fault_tolerant_router.conf configuration file is in [YAML](http://en.wikipedia.org/wiki/YAML) format. Here is the explanation of some of the options:

* **uplinks**: array of uplinks. The example configuration has 3 uplinks, but you can have from 2 to as many as you wish.
  * **interface**: the network interface where the uplink is attached. Until today Fault Tolerant Router has always been used with each uplink on it's own physical interface, never tried with VLAN interfaces (it's in the to do list).
  * **ip**: primary IP address of the network interface. You can have more than one IP address assigned to the interface, just specify the primary one.
  * **gateway**: the gateway on this interface, usually the provider's router IP address.
  * **description**: used in the alert emails.
  * **weight**: optional parameter, it's the preference to assign to the uplink when choosing one for a new outgoing connection. Use when you have uplinks with different bandwidths. See http://www.policyrouting.org/PolicyRoutingBook/ONLINE/CH05.web.html
  * **default_route**: optional parameter, default value is *true*. If set to *false* the uplink is excluded from the multipath routing, i.e. the uplink will never be used when choosing one for a new outgoing connection. Exception to this is if some kind of outgoing connection is forced to pass through this uplink, see [iptables](#Iptables-rules) section. Even if set to *false*, incoming connections are still possible. Use cases to set it to *false*:
    * Want to reserve an uplink for incoming connections only, excluding it from outgoing LAN internet traffic. Tipically you may want this because you have a mail server, web server, etc. listening on this uplink.
    * Temporarily force all of the outgoing LAN internet traffic to pass through the other uplinks, to stress test the other uplinks and determine their bandwidth
    * Temporarily exclude the uplink to do some reconfiguration, for example changing one of the internet providers.

* **downlinks**
  * **lan**: LAN interface
  * **dmz**: DMZ interface, leave blank if you have no DMZ

* **tests**
  * **ips**: an array of IPs to ping to verify the uplinks state. You can add as many as you wish. Predefined ones are Google DNS, OpenDNS DNS, other public DNS. Every time an uplink is tested the ips are shuffled, so listing order has no importance.
  * **required_successful**: number of successfully pinged ips to consider an uplink to be functional
  * **ping_retries**: number of ping retries before giving up on an ip
  * **interval**: seconds between a check of the uplinks and the next one

* **log**
  * **file**: log file path
  * **max_size**: maximum log file size (in bytes). Once reached this size, the log file will be rotated.
  * **old_files**: number of old rotated files to keep

* **email**
  * **send**: set to *true* or *false* to enable or disable email notification
  * **sender**: email sender
  * **recipients**: an array of email recipients
  * **smtp_parameters**: see http://ruby-doc.org/stdlib-2.2.0/libdoc/net/smtp/rdoc/Net/SMTP.html

* **base_table**: just need to change if you are already using [multiple routing tables](http://lartc.org/howto/lartc.rpdb.html), to avoid overlapping
* **base_priority**: just need to change if you are already using [ip rule](http://lartc.org/howto/lartc.rpdb.html), to avoid overlapping
* **base_fwmark**: just need to change if you are already using packet marking, to avoid overlapping

## Iptables rules
Iptables rules are generated using the command
`$ fault_tolerant_router generate_iptables`
The rules are in [iptables-save](http://manned.org/iptables-save.8) format, you should integrate them with your existing ones.

Rules are documented directly in the generated output. Here is the dump of the generated rules (including comments) using the standard example configuration.










Mangle section:
```
#new outbound connections: force connection to use a specific uplink instead of letting multipath routing decide (for
#example for an SMTP server). Uncomment if needed.
```
You can optionally force some kind of outgoing connection to always use a specific uplink instead of participating in the multipath routing: this could be useful if you have an SMTP server that should always send emails from a specific IP address (because of PTR DNS records), or if you have some service that you want always be using a particular slow of fast uplink.
Nat section:
```
#DNAT: WAN --> DMZ. Uncomment if needed.
```
You can optionally activate destination NAT on any IP address of the uplink interfaces.
```
#SNAT: LAN/DMZ --> WAN: force the usage of a specific source address (for example for an SMTP server). Uncomment if needed.
```
You can optionally force some kind of outgoing connection to be *source-natted* from a specific IP address instead of the default one of the outgoing interface. This could be useful in case of an SMTP server that should always send emails from a specific IP address (because of PTR DNS records).

## To do
- Improve documentation: please let me know where it's not clear.
- Test VLAN interfaces: Fault Tolerant Router has always been used with physical interfaces, each uplink on it's own physical interface.
- Implement routing through [realms](http://www.policyrouting.org/PolicyRoutingBook/ONLINE/CH07.web.html): this way we could connect all of the uplinks to a single Linux physical interface through a switch, without using VLANs.
- i18n

## License
GNU General Public License v2.0, see LICENSE file

## Author
Alessandro Zarrilli - <alessandro@zarrilli.net>
