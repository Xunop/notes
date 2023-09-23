sudo guestmount -a Workspace/qemu_conf/opE/arm64-vm-3.img -i --rw /mnt/vm
sudo make ARCH=arm64 INSTALL_MOD_PATH=/mnt/vm modules_install
sudo make ARCH=arm64 INSTALL_PATH=/mnt/vm/boot install
sudo guestunmount /mnt/vm
