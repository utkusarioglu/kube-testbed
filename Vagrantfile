require 'yaml'
auth_path = File.join(File.dirname(__FILE__), 'auth.yml')
auth = YAML.load(File.read(auth_path))



#TODO computer name and user needs to be different for kube to work
#TODO networking settings

# Machines common vars
machines_image = "hashicorp/bionic64"
machines_image_version = "1.0.282"
machines_prefix = "v"
provision_workers = false

# Networking vars
network_ip = "192.168.0"
gateway_ip = "#{network_ip}.1"
switch_name = "NATSwitch"
bridge = "Default Switch"

Vagrant.configure("2") do |config|

    # SSH
    config.ssh.username = auth["ssh"]["username"]
    config.ssh.password = auth["ssh"]["password"]

    # Switch
    config.trigger.before :up do |trigger|
        trigger.info = "Creating 'NATSwitch' Hyper-V switch if it does not exist..."
        trigger.run = {
            privileged: "true", 
            powershell_elevated_interactive: "true", 
            path: "./scripts/create-nat-hyperv-switch.ps1",
        }
    end

    # Shared folders
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.synced_folder ".\\shared", "/shared", 
        type: "smb",
        create: true,
        smb_username: auth["smb"]["username"],
        smb_password: auth["smb"]["password"],
        mount_options: [
            "vers=3.0", 
        ]

    # Master
    master_name = "#{machines_prefix}1"
    master_ip = "#{network_ip}.2"

    config.vm.define master_name, primary: true do |master|
        master.vm.box = machines_image
        master.vm.box_version = machines_image_version
        master.vm.disk :disk, size: "5GB", primary: true
        master.vm.provider "hyperv" do |hyperv|
            hyperv.vmname = master_name
            hyperv.memory = 1024
            hyperv.maxmemory = 2048
            hyperv.cpus = 2
            hyperv.enable_virtualization_extensions = true
            hyperv.linked_clone = true
        end

        config.trigger.before :reload do |trigger|
            trigger.info = "Setting Hyper-V switch to 'NATSwitch' for static IP"
            trigger.run = {
                privileged: "true", 
                powershell_elevated_interactive: "true", 
                path: "./scripts/set-hyperv-switch.ps1",
                args: [
                    master_name
                ]
            }
        end

        # is_first_time = !Dir.exist?(File.join(File.dirname(__FILE__), '.vagrant/machines/', master_name))
        # puts "first?"
        # if is_first_time
        #     puts "yes, first"
        #     master.vm.network "public_network", 
        #         bridge: bridge
        # # else
        # #     master.vm.network "public_network", auto_config: false
        # end
        
        master.vm.provision "shell", 
            name: "ip",
            path: "./scripts/configure-static-ip.sh",
            env: {
                "MACHINE_NAME" => master_name,
                "MACHINE_IP4" => master_ip,
                "GATEWAY_IP4" => gateway_ip
            }

        master.vm.provision :reload

        # master.vm.provision "shell",
        #     name: "master",
        #     after: "common",
        #     path: "master.sh",
        #     env: {
        #         "MACHINE_NAME" => master_name,
        #         "MACHINE_IP4" => master_ip 
        #     }

    end

    # Workers
    if provision_workers
        worker_count = 2
        (1..worker_count).each do |i|

            worker_no = i + 1
            worker_name = "#{machines_prefix}#{worker_no}"
            host_ip = worker_no + 1
            worker_ip = "#{network_ip}.#{host_ip}"

            config.vm.define worker_name do |worker|
                worker.vm.box = machines_image
                worker.vm.box_version = machines_image_version
                worker.vm.disk :disk, size: "5GB", primary: true
                worker.vm.provider "hyperv" do |hyperv|
                    hyperv.vmname = worker_name
                    hyperv.memory = 512
                    hyperv.maxmemory = 1024
                    hyperv.cpus = 1
                    hyperv.enable_virtualization_extensions = true
                    hyperv.linked_clone = true
                end

                config.trigger.before :reload do |trigger|
                    trigger.info = "Setting Hyper-V switch to 'NATSwitch' for static IP"
                    trigger.run = {
                        privileged: "true", 
                        powershell_elevated_interactive: "true", 
                        path: "./scripts/set-hyperv-switch.ps1",
                        env: {
                            "MACHINE_NAME" => worker_name,
                            "SWITCH_NAME" => switch_name
                        }
                    }
                end

                config.trigger.before :up do |trigger|
                    trigger.info = "\n\n\n\n worker triggered"
                    worker.vm.network "public_network", 
                        bridge: bridge
                end

                # worker.vm.network "public_network", 
                #     bridge: bridge

                worker.vm.provision "shell", 
                    name: "ip",
                    path: "./scripts/configure-static-ip.sh",
                    env: {
                        "MACHINE_NAME" => worker_name,
                        "MACHINE_IP4" => worker_ip,
                        "GATEWAY_IP4" => gateway_ip
                    }
                
                worker.vm.provision :reload

                worker.vm.provision "shell",
                    name: "worker",
                    after: "master",
                    path: "worker.sh",
                    env: {
                        "MACHINE_NAME" => worker_name,
                        "MACHINE_IP4" => worker_ip
                    }

            end
        end
    end



    # config.vm.provision "shell",
    #     name: "common",
    #     after: "ip",
    #     path: "common.sh"


end