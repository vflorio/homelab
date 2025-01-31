# Proxmox Full-Clone
# ---
# Create a new VM from a clone

resource "proxmox_vm_qemu" "srv-demo-0" {
    
    # VM General Settings
    target_node = "homelab"
    vmid = "2200"
    name = "srv-demo-0"
    desc = "Ubuntu Demo 0 Server"

    # VM Advanced General Settings
    onboot = false 

    # VM OS Settings
    clone = "ubuntu-server-noble"

    # VM System Settings
    agent = 1
    boot = "order=virtio0;ide2"

    # VM CPU Settings
    cores = 2
    sockets = 1
    cpu_type = "host"
    
    # VM Memory Settings
    memory = 2048

    # VM Network Settings
    network {
        id = 0
        bridge = "vmbr0"
        model  = "virtio"
    }

    # VM Disk Settings
    disks {
        ide {
            ide2 {
                cloudinit {
                    storage = "local-lvm"
                }
            }
        }
        virtio {
            virtio0 {
                disk {
                    format = "raw"
                    storage = "local-lvm"
                    size = 20
                }
            }
        }
    }

    # VM Cloud-Init Settings
    os_type = "cloud-init"

    # (Optional) IP Address and Gateway
    ipconfig0 = "ip=192.168.1.180/24,gw=192.168.1.254"

    # (Optional) Default User
    ciuser = "vflorio"
    
    # (Optional) Add your SSH KEY
    sshkeys = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCQmV7zookw6fRhx0wYqgZUmQWOMyGMKFUSpXOxX2ovkETBGDabU7st9tTK6K3zxykVPUGM1cwhQuGhB9fAiWlGAMF2WcMyBclBYEz1s9pJenyUX25ui47rwu6npjVAQN0DclWc9x/v0ooiASthIlF7CZsw8VK0S0EHw5MqObUMKrgVn/+SI63E0XT1qN6cOgFfeCpnAk6u2u/rTZyscpGQUnL0JXGN44gflKDFFs8LoMAly6wVzQn0SzLdrMzeVNKCwAWXH2DxPYLOrdMkjkm/qq8dpUt7v1zi9L65Ci0TJWOONJ1jCOFJNVh8YGAXQazYdfUIf2pi6nRRsVYbqoQTDlmXc6xHJgB9ppaiA9wpK4cW5bz9vcQBTfZxl71Woz0fMV9KWEt2xP08ovThhaZnngBKaPt6bo+gKihquDhVokTNsxOEhbNfuh09wNa2ZoQwTKPlADDrXvH3HgmT0jKSO/OdNQECp9DI4UQm0ttMiIMz1/VCR0oazlJGRyqGp28WEsUQiKp7iPfrB8IEKgxtXPUUW4h1b6NuuS7tWOdR4YRNFd0PyJ4Z83vNzgllePvj7fjYoohESer5zWc138ae03hHmAeAPPlobi41gq2iPAVUSkbSoklqLWhfq7LRw5hsNMgKCLtc+2q8iv7ADarCYkb95J3IbjC9J/rbOcwQDw== floriovincenzo98@gmail.com
    EOF
}
