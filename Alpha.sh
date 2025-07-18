#!/bin/bash

# ====== BUILD SECTION ======

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests

# Initialize repo for Alphadroid
repo init -u https://github.com/alphadroid-project/manifest -b alpha-15.2 --git-lfs

# Sync
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync

# Clone device/vendor/kernel repositories
git clone https://github.com/Hans982/android_device_google_coral device/google/coral -b lineage-22.2
git clone https://github.com/Hans982/android_device_google_gs-common device/google/gs-common -b lineage-22.2
git clone https://github.com/Hans982/android_kernel_google_msm-4.14 kernel/google/msm-4.14 -b lineage-22.2

# Build Environment
export BUILD_USERNAME=Hans982; \
export BUILD_HOSTNAME=crave; \
export TZ=Asia/Tokyo; \

# Build
source build/envsetup.sh 
lunch alpha_flame-userdebug && mka bacon
