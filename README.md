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

3. Optional: demo how the daemon works, useful if it's the first time you see it:
`$ fault_tolerant_router --demo monitor`

4. Generate iptables rules and integrate them with your existing ones:
`$ fault_tolerant_router generate_iptables`

5. Optional: test email notification, to be sure SMTP parameters are correct and the administrator will get notifications:
`$ fault_tolerant_router email_test`
6. Run the daemon:
`$ fault_tolerant_router monitor`
Previous command will actually run Fault Tolerant Router in foreground. To run it in background you should use your Linux distribution specific method to start it as a system service. See for example [start-stop-daemon](http://manned.org/start-stop-daemon).
If you want a quick and dirty way to run the program in background, just add an ampersand at the end of the command line
`$ fault_tolerant_router monitor &`

## Configuration file

## Iptables rules

## Uplink monitor algorithm

## To do
- Test it with VLAN interfaces (has always been used with physical interfaces: each uplink on it's own physical interface)
- Implement routing through [realms](http://www.policyrouting.org/PolicyRoutingBook/ONLINE/CH07.web.html), this way we could have all of the uplinks attached via a switch to a single Linux physical interface, without using VLANs
- Use [Ruby Daemons](https://github.com/thuehlinger/daemons)
- i18n

## License
GNU General Public License v2.0, see LICENSE file

## Author
Alessandro Zarrilli - <alessandro@zarrilli.net>
