# Home Network Documentation

## Overview

Devices talk to each other using a set of protocols called [TCP/IP](https://simple.wikipedia.org/wiki/Internet_protocol_suite) - similar to a spoken language between people. You don't need to know most of the details about them, only that they exist in case the term pops up. Devices may use these protocols:

- Over [ethernet](https://simple.wikipedia.org/wiki/Ethernet) cables (usually faster)
- Wirelessly (usually more convenient)

A pair of devices must be configured properly in order to communicate with each other. As the number of devices in the home grows, these settings would grow exponentially (every device having to specifically know about every other device), which would make it very difficult to manage and maintain.

To solve this problem, there are specific devices dedicated to managing connections between devices - using a "[hub-and-spoke](https://simple.wikipedia.org/wiki/Transport_hub)" pattern:

- A [Hub](https://simple.wikipedia.org/wiki/Ethernet_hub) connects multiple wired devices. Each device only needs to send requests to the hub, and the hub will forward those requests to the proper destination.
- A [Switch](https://simple.wikipedia.org/wiki/Ethernet_switch) is basicaly just a fancy hub - they do the same thing, but switches are more efficient. As switches have become cheaper, actual hubs aren't used much anymore and the terms have become somewhat synonymous.
- A **W**ireless **A**ccess **P**oint ([WAP](https://simple.wikipedia.org/wiki/Wireless_access_point)) is essentially the same thing as a switch, only using wireless signals instead of ethernet cables.

These devices, and the devices connected to them, make up what we call a **L**ocal **A**rea **N**etwork ([LAN](https://simple.wikipedia.org/wiki/Local_area_network)) or home network. All the devices on this network can communicate freely with each other, with no restrictions.

When we want to connect our home network to the internet - sometimes called a **W**ide **A**rea **N**etwork ([WAN](https://simple.wikipedia.org/wiki/Wide_area_network)), we run into some new problems. Mostly, we don't trust everyone out there in that bigger network! We also can't keep track of all the computers out there and how to communicate with them.

To solve this problem, we need what's called a [router](https://simple.wikipedia.org/wiki/Router). It connects two different networks together, and allows traffic to flow between them without them having to know each other's details. While hubs and switches simply plug in and work, a router is smart - it's basically a mini computer running Linux. It has a lot of configuration options.

A [gateway](https://simple.wikipedia.org/wiki/Gateway_(computer_networking)) is a special kind of router that contains additional features specifically geared towards connecting home networks to the internet - such as a [firewall](https://en.wikipedia.org/wiki/Firewall_(computing)) to block unsolicited traffic, as well as monitoring and filtering options for online content.

## Current Equipment

The [Asus RT-AC1750](https://www.asus.com/us/Networking/RT-AC1750/) is a gateway router and WAP rolled into one. This device provides access to the internet, and connect all our wireless devices together. To access all the configuration options for the router, you can simply browse to [router.asus.com](http://router.asus.com) from inside the LAN, and the router will intercept it as if it were a real website.

The [Netgear GS324](https://www.netgear.com/home/products/networking/switches/soho-ethernet-switches/GS324.aspx) switch connects all our wired devices together. It's also plugged into the router, so the _wired_ devices can communicate with the _wireless_ ones, as well as the internet.

## Addressing

Every house must have a street address in order for mail to be delivered to it. In the same way, every device must have an [IP address](https://simple.wikipedia.org/wiki/IP_address) assigned to it in order for network traffic to be delivered to it.

When we sign up with an [ISP](https://simple.wikipedia.org/wiki/Internet_service_provider) - currently [Vivint](https://vivintinternet.com/) - they assign our router a [public IP address](https://www.google.com/search?q=public+ip+address). This address is available to the whole world - if you type it in any browser, anywhere, your request will be directed to our router at home. (Currently, the router's firewall will block the request and the browser won't know there's anything there. For security. 🙂)

The number of available public IP addresses is limited, so we're only allowed to have the one. (The ISP may even change it on us from time to time, but the router will handle this automatically.) However, a specific range of IP addresses ([192.168.xxx.xxx](https://simple.wikipedia.org/wiki/Private_network)) is specifically reserved for internal LAN use. We can use these ~65,000 addresses for whatever we want - but so can everyone else. Since they're not globally unique, they're not valid in the wider internet.

So anytime a device on our home network sends a request out to the internet, the router has to perform **N**etwork **A**ddress **T**ranslation ([NAT](https://simple.wikipedia.org/wiki/Network_address_translation)) to convert that device's _private IP address_ into our family's _public IP address_ as the 'from' address. And when the response comes back from the internet, the router has to remember which device it was meant for, and forward it accordingly.

So from the internet's point of view, everything in our house appears like one single device with one single IP address, handling lots of different traffic all at the same time.

### MAC Addresses

Every piece of networking equipment is given a semi-random, unique identifier code, called a [MAC address](https://simple.wikipedia.org/wiki/MAC_address), in the format of six [hexidecimal](https://simple.wikipedia.org/wiki/Hexadecimal) numbers (bytes) separated by colons (`1a:2b:3c:4d:5e:6f`). This is usually burned into networking hardware, and cannot be changed. It's purpose is to uniquely identify that specific hardware on a network.

The reason MAC addresses can't just be used in place of IP addresses, is because the IP address needs to be controlled by the network, not the device. If you disconnect your device from one network and connect to another, you need a new IP address inside that network.

Since MAC addresses are not changeable, they don't serve this purpose well.

### Dynamic IP Addresses

When deciding how to divvy up the IP addresses from the private range to the various devices in our home network, there are a couple of ways to do it.

One way is to define a range (or _pool_) of available IP addresses, and let the router dynamically assign a random address from the pool to any LAN device that connects to it. The assignments are temporary, so the IP addresses are returned to the pool after a certain amount of time. If a device wants to remain connected, it must ask for a new IP address from the pool.

This feature is called the **D**ynamic **H**ost **C**onfiguration **P**rotocol ([DHCP](https://simple.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol)), and is usually enabled by default. It's super convenient because almost no configuration is needed on the connecting device; they just ask for an address whenever they need one.

However, due to the temporary nature of these address assignments, sometimes conflicts can arise. If two devices try to use the same address at the same time, they will get network errors. For this reason, DHCP is usually best suited for temporary connections - such as when visitors want to connect to our WiFi.

Currently our router is confiugred to only use addresses in the `192.168.1.xxx` range, for convenience. (Only the last number in the quad varies.) This is a common approach for most home networks, and gives us 255 addresses to work with. The root address (`192.168.1.0`) represents the network itself, so no devices are ever assigned to that one.

The router's DHCP server has been given the range of addresses from `192.168.1.100` to `192.168.1.199` to use for its pool. This means 100 friends could all connect at the same time without running out of addresses.

### Static IP Addresses

For devices that we know about, and which connect regularly to our home network, we can manually assign addresses for them. These addresses will be reserved and dedicated specifically to these devices, and never expire - so they run no risk of conflicts. This takes more manual configuration, but gives more stable performance to those devices.

Here are the static IP address assignments as currently registered:

#### Network

| Device MAC Address  | Device Name              | Assigned IP Address | Registered |
| ------------------- | ------------------------ | ------------------- | ---------- |
| N/A                 | _\<network broadcast\>_  | `192.168.1.0`       | N/A        |
| `88:d7:f6:65:1b:68` | Asus Router              | `192.168.1.1`       | ✔️         |
| `8c:e2:da:f4:0b:27` | Disney Circle (Ethernet) | `192.168.1.2`       | ✔️         |
| `8c:e2:da:f4:0b:28` | Disney Circle (WiFi)     | `192.168.1.3`       | ✔️         |

#### Smoke Alarms

| Device MAC Address  | Device Name                     | IP Address     | Registered |
| ------------------- | ------------------------------- | -------------- | ---------- |
| `64:16:66:c7:63:7e` | Upstairs - Living room          | `192.168.1.11` | ✔️         |
| `64:16:66:c7:49:49` | Upstairs - Hallway              | `192.168.1.12` | ✔️         |
| `64:16:66:c7:50:a9` | Upstairs - Office               | `192.168.1.13` | ✔️         |
| `64:16:66:c7:65:7f` | Upstairs - Spare room           | `192.168.1.14` | ✔️         |
| `64:16:66:c7:67:10` | Upstairs - Master bedroom       | `192.168.1.15` | ✔️         |
| `64:16:66:c7:59:1f` | Downstairs - Oliver's bedroom   | `192.168.1.16` | ✔️         |
| `64:16:66:c7:40:0e` | Downstairs - Kitchenette        | `192.168.1.17` | ✔️         |
| `64:16:66:c7:63:6e` | Downstairs - Hallway            | `192.168.1.18` | ✔️         |
| `64:16:66:c7:51:77` | Downstairs - Isabelle's bedroom | `192.168.1.19` | ✔️         |

#### Home

| Device MAC Address  | Device Name          | IP Address     | Registered |
| ------------------- | -------------------- | -------------- | ---------- |
| `64:16:66:6e:3d:cd` | Nest Hello           | `192.168.1.20` | ✔️         |
| `18:b4:30:d3:0f:97` | Nest Thermostat E    | `192.168.1.21` | ✔️         |
| `b8:d7:af:28:ef:ce` | Rachio 3             | `192.168.1.22` | ✔️         |
| `00:07:a6:13:bb:0d` | Leviton Smart Dimmer | `192.168.1.23` | ✔️         |
| `00:1b:a9:81:78:ba` | Printer (Ethernet)   | `192.168.1.24` | ✔️         |
| `00:22:58:78:55:0f` | Printer (WiFi)       | `192.168.1.25` | ✔️         |
| `20:df:b9:82:73:c7` | Google Home Mini     | `192.168.1.26` | ✔️         |

#### Entertainment

| Device MAC Address  | Device Name                | IP Address     | Registered |
| ------------------- | -------------------------- | -------------- | ---------- |
| `20:17:42:97:22:f0` | LG TV (Ethernet)           | `192.168.1.30` | ✔️         |
| `60:ab:14:36:a5:00` | LG TV (WiFi)               | `192.168.1.31` | ✔️         |
| `00:05:cd:ba:16:14` | Denon Receiver (Ethernet)  | `192.168.1.32` | ✔️         |
| `00:05:cd:ba:16:16` | Denon Receiver (WiFi)      | `192.168.1.33` | ✔️         |
| `7c:ed:8d:c1:d2:4c` | XBox 360 (Ethernet & WiFi) | `192.168.1.34` | ✔️         |
| `b8:31:b5:c5:94:a9` | XBox One X (Ethernet)      | `192.168.1.35` | ✔️         |
| `b8:31:b5:c5:94:ab` | XBox One X (WiFi)          | `192.168.1.36` | ✔️         |
| `64:b5:c6:ba:83:17` | Nintendo Switch            | `192.168.1.37` | ✔️         |
| `e0:31:9e:33:ad:2b` | Steam Link (Ethernet)      | `192.168.1.38` | ✔️         |
| `e0:31:9e:33:ad:2c` | Steam Link (WiFi)          | `192.168.1.39` | ✔️         |
| `78:84:3c:68:03:9f` | Blu-Ray Player (Ethernet)  | `192.168.1.40` | ✔️         |
| `00:a0:96:81:cb:23` | Blu-Ray Player (WiFi)      | `192.168.1.41` | ✔️         |
| `f4:f5:d8:95:07:d4` | Chromecast                 | `192.168.1.42` | ✔️         |

#### Computers

| Device MAC Address  | Device Name              | IP Address     | Registered |
| ------------------- | ------------------------ | -------------- | ---------- |
| `f8:ca:b8:29:52:45` | Family Laptop (Ethernet) | `192.168.1.50` | ✔️         |
| `78:0c:b8:b3:54:9d` | Family Laptop (WiFi)     | `192.168.1.51` | ✔️         |
| `18:db:f2:26:e6:3b` | WTW Laptop (Ethernet)    | `192.168.1.52` | ✔️         |
| `e4:b3:18:3a:c2:5d` | WTW Laptop (WiFi)        | `192.168.1.53` | ✔️         |

#### Phones

| Device MAC Address  | Device Name        | IP Address     | Registered |
| ------------------- | ------------------ | -------------- | ---------- |
| `ac:37:43:a6:39:87` | RJ's Pixel XL      | `192.168.1.60` | ✔️         |
| `40:4e:36:7f:55:2f` | Rusti's Pixel XL   | `192.168.1.61` | ✔️         |
| `88:b4:a6:3b:7d:30` | Isabelle's Moto X4 | `192.168.1.62` | ✔️         |
| `88:b4:a6:75:d6:c8` | Oliver's Moto X4   | `192.168.1.63` | ✔️         |
