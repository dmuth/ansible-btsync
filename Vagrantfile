# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

	#
	# Cache anything we download with apt-get
	#
	if Vagrant.has_plugin?("vagrant-cachier")
		config.cache.scope = :box
	end

	config.vm.define :btsync do |btsync|

		btsync.vm.box = "precise64"
		btsync.vm.box_url = "http://files.vagrantup.com/precise64.box"

		#
		# Drop both of these, as we have no need for web traffic
		#
		btsync.vm.network :forwarded_port, guest: 80, host: 8080
		btsync.vm.network :forwarded_port, guest: 443, host: 8443

		#
 		# Splunk HTTPS
		#
		btsync.vm.network :forwarded_port, guest: 8000, host: 8000

		#
		# Drop HTTP to BTSync
		#
		btsync.vm.network :forwarded_port, guest: 8888, host: 8888

		#
		# BTSync HTTPS wrapper
		#
		btsync.vm.network :forwarded_port, guest: 8889, host: 8889

		#
		# Set the amount of RAM and CPU cores
		#
		btsync.vm.provider "virtualbox" do |v|
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


