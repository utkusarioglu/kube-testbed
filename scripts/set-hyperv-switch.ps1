# See: https://www.thomasmaurer.ch/2016/01/change-hyper-v-vm-switch-of-virtual-machines-using-powershell/
$MACHINE_NAME=$args[0]
$SWITCH_NAME="NATSwitch"
Get-VM $MACHINE_NAME | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName $SWITCH_NAME