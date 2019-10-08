Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu1804"
  config.vm.hostname = "WebMysql"
  config.vm.network "private_network", ip: "192.168.100.100"
  config.vm.synced_folder "src", "/vagrant", create: true
  config.vm.provider :libvirt
  config.vm.provision "shell", path: "src/testscript"
end

