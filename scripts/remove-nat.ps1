Remove-VMSwitch -SwitchName "NATSwitch"
Remove-NetIPAddress -IPAddress 192.168.0.1
Remove-NetNAT -Name "NATNetwork"