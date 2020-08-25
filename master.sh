echo "Master Provisioning Started"                                                                                      | tee -a /shared/events.log

echo "Pull kube images"                                                                                                 | tee -a /shared/events.log
kubeadm config images pull                                                                                              2>>/shared/error.log 1>>/shared/events.log
echo "Switch to root"                                                                                                   | tee -a /shared/events.log
sudo su -                                                                                                               2>>/shared/error.log 1>>/shared/events.log

echo "CIDR set"                                                                                                         | tee -a /shared/events.log
kubeadm init --pod-network-cidr=192.168.0.0/16                                                                          2>>/shared/error.log 1>>/shared/events.log

echo "Admin.conf"                                                                                                       | tee -a /shared/events.log
export KUBECONFIG=/etc/kubernetes/admin.conf                                                                            2>>/shared/error.log 1>>/shared/events.log
sudo cp /etc/kubernetes/admin.conf /shared/admin.conf                                                                   2>>/shared/error.log 1>>/shared/events.log

echo "Allow admins"                                                                                                     | tee -a /shared/events.log
mkdir -p $HOME/.kube                                                                                                    2>>/shared/error.log 1>>/shared/events.log
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config                                                                2>>/shared/error.log 1>>/shared/events.log
sudo chown $(id -u):$(id -g) $HOME/.kube/config                                                                         2>>/shared/error.log 1>>/shared/events.log

echo "Switch to vagrant user"                                                                                           | tee -a /shared/events.log
su - vagrant

echo "Flannel"                                                                                                          | tee -a /shared/events.log
sysctl net.bridge.bridge-nf-call-iptables=1                                                                             2>>/shared/error.log 1>>/shared/events.log

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml                 2>>/shared/error.log 1>>/shared/events.log
kubectl taint nodes --all node-role.kubernetes.io/master-                                                               2>>/shared/error.log 1>>/shared/events.log

echo "Join token"                                                                                                       | tee -a /shared/events.log
#Notice that stdout redirection is different in this one
kubeadm token create --print-join-command > /shared/join.sh                                                             2>>/shared/error.log 1>/shared/join.sh

echo "Master Provisioning Complete"                                                                                     | tee -a /shared/events.log