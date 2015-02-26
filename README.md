# Fault Tolerant Router

Fault Tolerant Router is a daemon, running in background on a Linux router or firewall, monitoring the state of multiple internet uplinks/providers and changing the routing accordingly. Outgoing connections are spread through the uplinks in a load balancing fashion via Linux multipath routing. Fault Tolerant Router monitors the state of the uplinks by routinely pinging well known IP addresses (for example Google public DNS servers) through each outgoing interface. Once an uplink goes down, it is excluded from the multipath routing. When it comes back up, it is included again. All of the routing changes are notified to the administrator by email.

Fault Tolerant Router is well tested and has been used in production for several years, in several sites.

## Requirements

[Ruby](https://www.ruby-lang.org)

## Installation
    $ gem install fault_tolerant_router
_NB: gem not yet published, want to have a better documentation first_

## Usage

1. Save an example configuration file in /etc/fault_tolerant_router.conf (use the --config option to set another location):  
`$ fault_tolerant_router generate_config`

2. Edit /etc/fault_tolerant_router.conf

3. _(Optional)_ Demo how the daemon works, useful if it's the first time you see it:  
`$ fault_tolerant_router --demo monitor`

4. Generate iptables rules and integrate them with your existing ones:  
`$ fault_tolerant_router generate_iptables`

5. _(Optional)_ Test email notification, to be sure SMTP parameters are correct and the administrator will get notifications:  
`$ fault_tolerant_router email_test`

6. Run the daemon:
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

## Iptables rules

## Uplink monitor algorithm

## To do
- Improve documentation (please let me know where it's not clear)
- Test it with VLAN interfaces (has always been used with physical interfaces: each uplink on it's own physical interface)
- Implement routing through [realms](http://www.policyrouting.org/PolicyRoutingBook/ONLINE/CH07.web.html), this way we could have all of the uplinks attached via a switch to a single Linux physical interface, without using VLANs
- Use [Ruby Daemons](https://github.com/thuehlinger/daemons)
- i18n

## License
GNU General Public License v2.0, see LICENSE file

## Author
Alessandro Zarrilli - <alessandro@zarrilli.net>

configura interfacce normalmente ma
disable default routing della distribuzione
il bilanciamento funziona per la lan
le connessioni passano sempre dallo stesso uplink per via del caching
