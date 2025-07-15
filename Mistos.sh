#!/bin/bash

# ====== BUILD SECTION ======

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests

# Initialize repo for Mist-os
repo init -u https://github.com/Project-Mist-OS/manifest -b 15 --git-lfs

# Sync
repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j$(nproc --all)

# Delete hardware/google/camera
rm -rf hardware/google/camera

# Clone device/vendor/kernel repositories
git clone https://github.com/LineageOS/android_hardware_google_camera --depth=1 hardware/google/camera
git clone https://github.com/Hans982/android_device_google_coral device/google/coral -b Mist-os
git clone https://github.com/Hans982/android_device_google_gs-common device/google/gs-common -b lineage-22.2
git clone https://github.com/Hans982/android_kernel_google_msm-4.14 kernel/google/msm-4.14 -b lineage-22.2

# Build Environment
export BUILD_USERNAME=Hans982; \
export BUILD_HOSTNAME=crave; \
export TZ=Asia/Tokyo; \

# Build
source build/envsetup.sh 
mistify flame userdebug && mist b
