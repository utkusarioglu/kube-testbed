require 'yaml'
auth_path = File.join(File.dirname(__FILE__), 'auth.yml')
auth = YAML.load(File.read(auth_path))



#TODO computer name and user needs to be different for kube to work
#TODO networking settings

# Machines common vars
machines_image = "hashicorp/bionic64"
machines_image_version = "1.0.282"
machines_prefix = "v"
worker_count = 2
run_provision_scripts = false

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

    #NatSwitch creation


    (1..(1 + worker_count)).each { |m|
        machine_name = "#{machines_prefix}#{m}"
        machine_ip = "#{network_ip}.#{m + 1}"

        config.vm.define machine_name, primary: true do |machine|

            machine.vm.box = machines_image
            machine.vm.box_version = machines_image_version
            machine.vm.disk :disk, size: "5GB", primary: true

            if m == 1
                # MASTER
                machine.vm.provider "hyperv" do |hyperv|
                    hyperv.vmname = machine_name
                    hyperv.memory = 1024
                    hyperv.maxmemory = 2048
                    hyperv.cpus = 2
                    hyperv.enable_virtualization_extensions = true
                    hyperv.linked_clone = true
                end

                if run_provision_scripts
                    master.vm.provision "shell",
                        name: "master",
                        after: "common",
                        path: "master.sh",
                        env: {
                            "MACHINE_NAME" => master_name,
                            "MACHINE_IP4" => master_ip 
                        }
                end

            else
                # WORKER
                machine.vm.provider "hyperv" do |hyperv|
                    hyperv.vmname = machine_name
                    hyperv.memory = 512
                    hyperv.maxmemory = 1024
                    hyperv.cpus = 1
                    hyperv.enable_virtualization_extensions = true
                    hyperv.linked_clone = true
                end

                if run_provision_scripts
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

            machine.vm.provision "shell", 
            name: "ip",
            path: "./scripts/configure-static-ip.sh",
            env: {
                "MACHINE_NAME" => machine_name,
                "MACHINE_IP4" => machine_ip,
                "GATEWAY_IP4" => gateway_ip
            }

            machine.trigger.before :reload do |trigger|
                trigger.info = "Setting Hyper-V switch to 'NATSwitch' for static IP"
                trigger.run = {
                    privileged: "true", 
                    powershell_elevated_interactive: "true", 
                    path: "./scripts/set-hyperv-switch.ps1",
                    args: [
                        machine_name
                    ]
                }
            end  

            machine.vm.provision :reload
        end
    }

    if run_provision_scripts
        config.vm.provision "shell",
            name: "common",
            after: "ip",
            path: "common.sh"
    end
end