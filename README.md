# Fault Tolerant Router

Fault Tolerant Router is a daemon, running in background on a Linux router or firewall, monitoring the state of multiple internet uplinks/providers and changing the routing accordingly. Outgoing connections are spread through the uplinks in a load balancing fashion via Linux multipath routing. Fault Tolerant Router monitors the state of the uplinks by routinely pinging well known IP addresses (for example Google public DNS servers) through each outgoing interface. Once an uplink goes down, it is excluded from the multipath routing. When it comes back up, it is included again. All of the routing changes are notified by email to the administrator.

Fault Tolerant Router is well tested and has been used in production for several years, in several sites.

## Requirements

[Ruby](https://www.ruby-lang.org)

## Installation

    $ gem install fault_tolerant_router

## Usage

    $ fault_tolerant_router

## To do
- improve documentation
- i18n
- test it with VLAN interfaces (has always been used with physical interfaces: each uplink on it's own physical interface)
- implement routing through [realms](http://www.policyrouting.org/PolicyRoutingBook/ONLINE/CH07.web.html), this way we could have all of the uplinks attached via a switch to a single Linux physical interface, without using VLANs

## License
GNU General Public License v2.0, see LICENSE file

## Author
Alessandro Zarrilli - <alessandro@zarrilli.net>
