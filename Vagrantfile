require 'yaml'

#Configs
auth_path = File.join(File.dirname(__FILE__), 'auth.yml')
auth = YAML.load(File.read(auth_path))

#TODO computer name and user needs to be different for kube to work
#TODO networking settings

machine_image = "hashicorp/bionic64"
machine_image_version = "1.0.282"
machine_name = "v"

Vagrant.configure("2") do |config|

    # Master
    config.vm.define "#{machine_name}1", primary: true do |master|
        master.vm.box = machine_image
        master.vm.box_version = machine_image_version
        master.vm.disk :disk, size: "5GB", primary: true
        master.vm.provider "hyperv" do |hyperv|
            hyperv.vmname = "#{machine_name}1"
            hyperv.memory = 1024
            hyperv.maxmemory = 2048
            hyperv.cpus = 2
        end

        # master.vm.network "public_network", 
        #     bridge: "External Static",
        #     mac: "08002700155D011C48",
        #     ip: "192.168.1.120",
        #     netmask: "255.255.255.0",
        #     gateway: "192.168.1.1",
        #     auto_config: false

        master.vm.network "public_network", 
            bridge: "Default Switch"
            # mac: "08002700155D011C48"
            # ip: "192.168.1.120"

        master.vm.provision "shell",
            name: "master",
            after: "common",
            path: "master.sh"

    end

    # Workers
    worker_count = 2
    (1..worker_count).each do |i|
        worker_no = i + 1
        worker_name = "#{machine_name}#{worker_no}"
        config.vm.define worker_name do |worker|
            worker.vm.box = machine_image
            worker.vm.box_version = machine_image_version
            worker.vm.disk :disk, size: "5GB", primary: true
            worker.vm.provider "hyperv" do |hyperv|
                hyperv.vmname = worker_name
                hyperv.memory = 512
                hyperv.maxmemory = 1024
                hyperv.cpus = 1
            end

            worker.vm.network "public_network", 
                bridge: "Default Switch"

            worker.vm.provision "shell",
                name: "worker",
                after: "master",
                path: "worker.sh"

        end
    end

    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.synced_folder "./shared", "/shared", 
        type: "smb",
        smb_username: auth["smb"]["username"],
        smb_password: auth["smb"]["password"] 

    config.ssh.username = auth["ssh"]["username"]
    config.ssh.password = auth["ssh"]["password"]

    config.vm.provision "shell",
        name: "common",
        path: "common.sh"
end