#!/bin/bash

# ====== BUILD SECTION ======

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests

# Initialize repo for Infinity-X
repo init -u https://github.com/Lunaris-AOSP/android -b 16 --git-lfs

# Sync
/opt/crave/resync.sh

# Clone device/vendor/kernel repositories
git clone https://github.com/Hans982/android_device_google_coral device/google/coral -b Lunaris-aosp
git clone https://github.com/Hans982/android_device_google_gs-common device/google/gs-common -b lineage-23.0
git clone https://github.com/Hans982/android_kernel_google_msm-4.14 kernel/google/msm-4.14 -b lineage-23.0

# Build Environment
export BUILD_USERNAME=Hans982; \
export BUILD_HOSTNAME=crave; \
export TZ=Asia/Tokyo; \

# Build
source build/envsetup.sh
lunch lineage_flame-userdebug && m lunaris
