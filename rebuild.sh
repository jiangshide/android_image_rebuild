#!/bin/bash

dd if=/dev/zero of=./system-rebuild.img bs=1M count=2000
dd if=/dev/zero of=./vendor-rebuild.img bs=1M count=100

mkfs.ext4 system-rebuild.img &&
mkfs.ext4 vendor-rebuild.img

mkdir -p system-rebuild vendor-rebuild

sudo mount system-rebuild.img system-rebuild
sudo mount vendor-rebuild.img vendor-rebuild

echo "挂载 AOSP 镜像"
mkdir system vendor
sudo mount -oro,barrier=1 system.img system
sudo mount -oro,barrier=1 vendor.img vendor

echo "定制 rebuild image"
sudo cp system/* system-rebuild/ -arf
sudo cp vendor/* vendor-rebuild/ -arf

####### TODO: Ugly Section ########
# TODO: 修改 logd 权限
sudo chmod 755 system-rebuild/system/bin/logd

# TODO: 创建 wayland 目录，做法不正确
sudo mkdir system-rebuild/wayland

sudo cp -a ugly/vendor/manifest.xml vendor-rebuild/
sudo cp -a ugly/vendor/ueventd.rc vendor-rebuild/

###################################

# /system/etc/init
sudo rm system-rebuild/system/etc/init/android.frameworks.bufferhub@1.0-service.rc
sudo rm system-rebuild/system/etc/init/bootanim.rc
sudo rm system-rebuild/system/etc/init/bufferhubd.rc
sudo rm system-rebuild/system/etc/init/cameraserver.rc
sudo rm system-rebuild/system/etc/init/nativeperms.rc
sudo rm system-rebuild/system/etc/init/performanced.rc
sudo rm system-rebuild/system/etc/init/virtual_touchpad.rc
sudo rm system-rebuild/system/etc/init/vr_hwc.rc
sudo rm system-rebuild/system/etc/init/wificond.rc
sudo rm system-rebuild/system/bin/bootanimation

echo "定制 /system/app"
# /system/app
sudo mv system-rebuild/system/app/ExtShared /tmp/
sudo mv system-rebuild/system/app/Traceur /tmp/
sudo rm system-rebuild/system/app/* -rf
sudo mv /tmp/ExtShared system-rebuild/system/app/
sudo mv /tmp/Traceur system-rebuild/system/app/

echo "定制 /system/priv-app"
# /system/priv-app
if [ ! -d /tmp/sysprivapp ]; then
    mkdir /tmp/sysprivapp
fi

cd system-rebuild/system/priv-app/
sudo mv DynamicSystemInstallationService \
    ExtServices ExternalStorageProvider \
    InputDevices ManagedProvisioning \
    PackageInstaller PermissionController \
    ProxyHandler SdkSetup SettingsProvider \
    SharedLibrary Shell StatementService \
    StatsdDogfood Tag UserDictionaryProvider /tmp/sysprivapp/
sudo rm * -rf
sudo mv /tmp/sysprivapp/* .
rm /tmp/sysprivapp -rf
cd -

echo "定制 /system/product/app"
# /system/product/app
sudo mv system-rebuild/system/product/app/webview /tmp/
sudo rm system-rebuild/system/product/app/* -rf
sudo mv /tmp/webview system-rebuild/system/product/app/

echo "定制 /system/product/priv-app"
# /system/product/priv-app
sudo mv system-rebuild/system/product/priv-app/Settings /tmp/
sudo rm system-rebuild/system/product/priv-app/* -rf
sudo mv /tmp/Settings system-rebuild/system/product/priv-app/

# /vendor/lib(64)/egl
# egl 符号链接在 LXC启动时处理
sudo rm vendor-rebuild/lib64/egl -rf
sudo rm vendor-rebuild/lib/egl -rf

# /vendor/lib64/hw
# 在 LXC 启动时处理
# ln -s camera.ranchu.so camera.default.so
# ln -s gatekeeper.ranchu.so gatekeeper.default.so
# ln -s gps.ranchu.so gps.default.so
# ln -s gralloc.ud710.so gralloc.default.so
# ln -s hwcomposer.ranchu.so hwcomposer.default.so
# ln -s sensors.ranchu.so sensors.default.so

# /vendor/lib/hw
# ln -s gralloc.ud710.so gralloc.default.so
# ln -s camera.ranchu.so camera.default.so

# /vendor/lib(64)
# cp
# android.hardware.audio.common@5.0-util.so libdrm.so libglslcompiler.so
# libIMGegl.so libsrv_um.so libusc.so

# TODO: 注意文件权限为 660
# /vendor/manifest.xml
# /vendor/ueventd.rc 在 LXC 启动时处理

echo "定制 vendor/priv-app"
sudo rm vendor-rebuild/priv-app/* -rf

echo "定制 vendor/etc/init"
sudo rm vendor-rebuild/etc/init/hw -rf
sudo rm vendor-rebuild/etc/init/rild.rc

echo "清理"
sudo umount system vendor
rm -rf system vendor
sudo umount system-rebuild vendor-rebuild
rm -rf system-rebuild vendor-rebuild

echo "放置 image"
if [ -d android-compatible-env/images ]; then
    rm -rf android-compatible-env/images
fi
mkdir -p android-compatible-env/images

if [ -d android-compatible-env/lxc ]; then
    rm -rf android-compatible-env/lxc
fi
mkdir -p android-compatible-env/lxc

git clone git@172.16.4.21:androidcompat/lxc_config.git android-compatible-env/lxc
chmod +x android-compatible-env/lxc/pre-start.sh
rm android-compatible-env/lxc/.git -rf

mv *-rebuild.img images

rm *.deb *.buildinfo *.changes

./create_deb.sh
