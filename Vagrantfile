# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

	if Vagrant.has_plugin?("vagrant-cachier")
		config.cache.scope = :box
	end

	config.vm.define :btsync do |btsync|
		btsync.vm.box = "precise64"
		btsync.vm.box_url = "http://files.vagrantup.com/precise64.box"
		btsync.vm.network :forwarded_port, guest: 80, host: 8080
		btsync.vm.network :forwarded_port, guest: 443, host: 8443
		btsync.vm.network :forwarded_port, guest: 8000, host: 8000
		btsync.vm.network :forwarded_port, guest: 8888, host: 8888
		btsync.vm.network :forwarded_port, guest: 8889, host: 8889
	end

end


