echo "Common Provisioning Starting"                                                                                     | tee -a /shared/events.log

echo "Docker"                                                                                                           | tee -a /shared/events.log
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y                                 2>>/shared/error.log 1>>/shared/events.log
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -                                            2>>/shared/error.log 1>>/shared/events.log
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"                       2>>/shared/error.log 1>>/shared/events.log
sudo apt update                                                                                                         2>>/shared/error.log 1>>/shared/events.log
sudo apt install docker-ce -y                                                                                           2>>/shared/error.log 1>>/shared/events.log
sudo usermod -aG docker $USER                                                                                           2>>/shared/error.log 1>>/shared/events.log

echo "Kubernetes"                                                                                                       | tee -a /shared/events.log
sudo su -                                                                                                               2>>/shared/error.log 1>>/shared/events.log
apt-get update && apt-get install -y apt-transport-https curl                                                           2>>/shared/error.log 1>>/shared/events.log
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -                                           2>>/shared/error.log 1>>/shared/events.log
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list 
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update                                                                                                          2>>/shared/error.log 1>>/shared/events.log
apt-get install -y kubelet kubeadm kubectl                                                                              2>>/shared/error.log 1>>/shared/events.log
apt-mark hold kubelet kubeadm kubectl                                                                                   >>/shared/error.log 1>>/shared/events.log

echo "Disable Swap"                                                                                                     | tee -a /shared/events.log
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab                                                                      2>>/shared/error.log 1>>/shared/events.log
sudo swapoff -a                                                                                                         2>>/shared/error.log 1>>/shared/events.log

echo "Common Provisioning Complete"                                                                                     | tee -a /shared/events.log