
# BitTorrent Sync Ansible Playbook

Awhile back, I felt it was time to move away from Dropbox, so I decided to try [BitTorrent Sync](http://www.bittorrent.com/sync).

The advantages of BitTorrent sync are that you can synchronize files in a Dropbox-like manner, but on whatever machines you want.  Desktops, laptops, Raspberry Pis, VMs from your faveorite cloud provider, whatever.  Use whatever machines you like.

This project is an Ansible playbook which can be used to set up BitTorrent Sync-enabled instances on Digital Ocean.

## System Requirements

- [Ansible 1.6 or greater](http://www.ansible.com/home) installed on the machine you will be managing instances from
- Ubuntu 12.04 LTS, 64-bit installed on each instance to manage

## Port usage

After running this playbook against an instance, the following ports will be affectd

- Port 80 - Blocked
- Port 443 - Blocked
- Port 8888 - Blocked. This is the default port that btsync uses, but in plaintext.  Very bad.
- Port 8889 
	- This port is opened by this Ansible playbook.  It speaks SSL using a self-signed certificate and proxies to localhost:8888.
	- This port is also used to access Munin for system stats, at https://the-hostname-or-ip:8889/munin/


## Testing with cheetahs

Once your instance is set up, you can test Bittorrent Sync with this key:

    BCXMRZ4G3KMWAY767FK26J2YQSE35S5Z7

This will download about 10 Megabytes of pictures of cheetahs to your node.


## Help contribute to this project!

I would be more than happy to add support for VMs from EC2, Rackspace, and other VPS providers.  Just let me know.


## Contact me

I can be found on the web at [http://www.dmuth.org/contact](http://www.dmuth.org/contact)
