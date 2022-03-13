android_image_rebuild
=====

定制 Android 兼容的系统镜像

说明
-----
AOSP 的 system 等镜像为只读文件系统，不对 AOSP 制作镜像的代码做任何修改，文件系统内的修改放在后面步骤处理


TODO
-----
- [x] 定制空的 system/vendor 文件系统
- [x] 定制 system
  - [x] system/etc/init 启动项定制
  - [x] system/app 定制
  - [x] system/priv-app 定制
  - [x] system/product/app 定制
  - [x] system/product/priv-app 定制
- [x] 定制 vendor
  - [x] vendor/lib(64)/egl 定制
  - [x] vendor/lib64/hw 定制  
        在 LXC 启动时处理  
```sh
        ln -s camera.ranchu.so camera.default.so
        ln -s gatekeeper.ranchu.so gatekeeper.default.so
        ln -s gps.ranchu.so gps.default.so
        ln -s gralloc.ud710.so gralloc.default.so
        ln -s hwcomposer.ranchu.so hwcomposer.default.so
        ln -s sensors.ranchu.so sensors.default.so
```

  - [x] vendor/lib/hw  
        在 LXC 启动时处理 
```sh
           ln -s gralloc.ud710.so gralloc.default.so
           ln -s camera.ranchu.so camera.default.so
```
  - [x] vendor/lib(64) 定制  
        缺少如下库可以先从 Host Vendor 中拷贝    
        第二版修改 ld.config 对库的回溯顺序
```sh
        android.hardware.audio.common@5.0-util.so
        libdrm.so libglslcompiler.so
        libIMGegl.so libsrv_um.so libusc.so
```
  - [x] vendor/priv-app 定制
  - [x] vendor/etc/init 定制
  - [x] vendor/ueventd & vendor/manifest.xml  
        这类修改过的文件先放在 deb 包中，安装的过程中进行拷贝

注意事项
----
文件权限修改

``` sh
chmod 600
/vendor/manifest.xml
/vendor/ueventd.rc
```
