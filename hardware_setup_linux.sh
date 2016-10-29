sudo killall jtagd
sudo chmod 755 /sys/kernel/debug/usb/devices
sudo chmod 755 /sys/kernel/debug/usb
sudo chmod 755 /sys/kernel/debug
sudo mount --bind /dev/bus /proc/bus
sudo rm /proc/bus/usb/devices
sudo ln -s /sys/kernel/debug/usb/devices /proc/bus/usb/devices
sudo /opt/quartus/bin/jtagd
sudo /opt/quartus/bin/jtagconfig
# Use this first inside quartus folder -- sudo cp -r linux/ linux64