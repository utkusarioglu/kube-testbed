echo "Worker Provisioning Starting"

sudo su -                                                               2>>/shared/error.log 1>>/shared/events.log

bash /shared/join.sh                                                    2>>/shared/error.log 1>>/shared/events.log

su - vagrant                                                            2>>/shared/error.log 1>>/shared/events.log

echo "Worker Provisioning Complete"