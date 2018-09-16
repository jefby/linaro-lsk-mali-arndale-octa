# build on Arndale OCTA board
# Working linaro image for sd card can be found at: http://releases.linaro.org/14.03/ubuntu/arndale-octa
set -x
set -e
sudo apt install -y u-boot-tools bc
# Initial config
export CC=gcc-4.9
export CXX=g++-4.9
./scripts/kconfig/merge_config.sh linaro/configs/linaro-base.conf linaro/configs/distribution.conf linaro/configs/arndale_octa.conf linaro/configs/lt-arndale_octa.conf linaro/configs/mali-arndale-octa.conf

# build
MINOR_VERSION=4
make zreladdr-y=0x20008000 LOCALVERSION=  KERNELVERSION=3.14.0-${MINOR_VERSION}-linaro-arndale-octa -j4 uImage modules dtbs
sudo make LOCALVERSION=  KERNELVERSION=3.14.0-${MINOR_VERSION}-linaro-arndale-octa modules_install 
#sudo make LOCALVERSION=  KERNELVERSION=3.14.0-${MINOR_VERSION}-linaro-arndale-octa modules_install INSTALL_MOD_PATH=/media/pi/rootfs/

# Mount boot partition, prepare for installkernel
sudo umount /dev/mmcblkp2
sudo mount /dev/mmcblk1p2 /media/boot
sudo rm -r /boot/*

# Install kernel
kernelversion=`cat ./include/config/kernel.release`
sudo installkernel $kernelversion ./arch/arm/boot/zImage ./System.map /boot

# Install device tree binary
sudo cp arch/arm/boot/dts/exynos5420-arndale-octa.dtb /media/boot/board.dtb
sudo cp arch/arm/boot/uImage /media/boot/

# Reboot
sudo sync
sudo umount /media/boot
echo "finished!!!!"
#sudo reboot

