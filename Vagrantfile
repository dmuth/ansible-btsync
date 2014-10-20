# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

	#
	# Cache anything we download with apt-get
	#
	if Vagrant.has_plugin?("vagrant-cachier")
		config.cache.scope = :box
	end

	#
	# This is our main host.  It also runs a Splunk indexer and search head.
	#
	config.vm.define :main do |host|

		host.vm.box = "precise64"
		host.vm.box_url = "http://files.vagrantup.com/precise64.box"
		host.vm.hostname = "main"
		host.vm.network "private_network", ip: "10.0.10.101"

		#
 		# Splunk HTTPS
		#
		host.vm.network :forwarded_port, guest: 8000, host: 8000

		#
		# BTSync HTTPS wrapper
		#
		host.vm.network :forwarded_port, guest: 8889, host: 8889

		#
		# BTSync HTTPS wrapper
		#
		host.vm.network :forwarded_port, guest: 9997, host: 9997

		#
		# Set the amount of RAM and CPU cores
		#
		host.vm.provider "virtualbox" do |v|
			v.memory = 512
			v.cpus = 2
		end

		#
		# Updating the plugins at start time never ends well.
		#
		if Vagrant.has_plugin?("vagrant-vbguest")
			config.vbguest.auto_update = false
		end

	end


	#
	# This is an additional host.
	# It will run BitTorrent Sync and a Splunk forwarder.
	#
	config.vm.define :forwarder do |host|

		host.vm.box = "precise64"
		host.vm.box_url = "http://files.vagrantup.com/precise64.box"
		host.vm.hostname = "forwarder"
		host.vm.network "private_network", ip: "10.0.10.102"

		#
		# BTSync HTTPS wrapper
		#
		host.vm.network :forwarded_port, guest: 8889, host: 8890

		#
		# Set the amount of RAM and CPU cores
		#
		host.vm.provider "virtualbox" do |v|
			v.memory = 512
			v.cpus = 2
		end

		#
		# Updating the plugins at start time never ends well.
		#
		if Vagrant.has_plugin?("vagrant-vbguest")
			config.vbguest.auto_update = false
		end

	end

end


