echo "Worker Provisioning Starting" | tee -a /shared/events.log

echo "Set static Ip" | tee -a /shared/events.log
cd /etc/netplan
cp "/shared/$MACHINE_NAME.yaml" $(ls)
sudo netplan apply

sudo su -                                                               2>>/shared/error.log 1>>/shared/events.log

bash /shared/join.sh                                                    2>>/shared/error.log 1>>/shared/events.log

su - vagrant                                                            2>>/shared/error.log 1>>/shared/events.log

echo "Worker Provisioning Complete" | tee -a /shared/events.log