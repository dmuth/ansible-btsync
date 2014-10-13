# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

	if Vagrant.has_plugin?("vagrant-cachier")
		config.cache.scope = :box
	end

	config.vm.define :btsync do |btsync|

		btsync.vm.box = "precise64"
		btsync.vm.box_url = "http://files.vagrantup.com/precise64.box"

		#
		# Port forwarding
		#
		btsync.vm.network :forwarded_port, guest: 80, host: 8080
		btsync.vm.network :forwarded_port, guest: 443, host: 8443
		btsync.vm.network :forwarded_port, guest: 8000, host: 8000
		btsync.vm.network :forwarded_port, guest: 8888, host: 8888
		btsync.vm.network :forwarded_port, guest: 8889, host: 8889

		#
		# Set the amount of RAM and CPU cores
		#
		btsync.vm.provider "virtualbox" do |v|
			v.memory = 512
			v.cpus = 2
		end

	end

end


