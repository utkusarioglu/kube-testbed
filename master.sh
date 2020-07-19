echo "Master Provisioning Started"

kubeadm config images pull                                                                                              2>>/shared/error.log 1>>/shared/events.log

sudo su -                                                                                                               2>>/shared/error.log 1>>/shared/events.log

echo "CIDR set"
kubeadm init --pod-network-cidr=192.168.0.0/16                                                                          2>>/shared/error.log 1>>/shared/events.log

echo "Admin.conf"
export KUBECONFIG=/etc/kubernetes/admin.conf                                                                            2>>/shared/error.log 1>>/shared/events.log
sudo cp /etc/kubernetes/admin.conf /shared/admin.conf                                                                   2>>/shared/error.log 1>>/shared/events.log

echo "Allow admins"
mkdir -p $HOME/.kube                                                                                                    2>>/shared/error.log 1>>/shared/events.log
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config                                                                2>>/shared/error.log 1>>/shared/events.log
sudo chown $(id -u):$(id -g) $HOME/.kube/config                                                                         2>>/shared/error.log 1>>/shared/events.log

su - vagrant

echo "Flannel"
sysctl net.bridge.bridge-nf-call-iptables=1                                                                             2>>/shared/error.log 1>>/shared/events.log

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml                 2>>/shared/error.log 1>>/shared/events.log
kubectl taint nodes --all node-role.kubernetes.io/master-                                                               2>>/shared/error.log 1>>/shared/events.log

echo "Join token"
#Notice that stdout redirection is different in this one
kubeadm token create --print-join-command > /shared/join.sh                                                             2>>/shared/error.log 1>/shared/join.sh

echo "Master Provisioning Complete"