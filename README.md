## RECOVERY branch for SM-T285

#### Requirements

* when building SHRP then special build/ repo must be used
* any repo from https://github.com/smt285/manifest

#### TWRP

1. sync TWRP to bootable/recovery-twrp
1. build:
~~~
rm -rf ./out/
cd bootable/ && rm recovery; ln -sf recovery-twrp recovery && croot && source build/envsetup.sh && lunch twrp_gtexslte-eng && mka recoveryimage
~~~

#### SHRP

1. sync SHRP to bootable/recovery-shrp
1. build:
~~~
rm -rf ./out/
cd bootable/ && rm recovery; ln -sf recovery-shrp recovery && croot && source build/envsetup.sh && lunch shrp_gtexslte-eng && mka recoveryimage
~~~

