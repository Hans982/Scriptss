#!/bin/bash

# ====== BUILD SECTION ======

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests

# Initialize repo for Infinity-X
repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault

# Sync
/opt/crave/resync.sh

# Delete hardware/google/camera
rm -rf hardware/google/camera

# Delete gs-common first
rm -rf device/google/gs-common

# Fix Clang overwritten by checkout
cd prebuilts/clang/host/linux-x86
git reset --hard HEAD
git clean -fd

# Clone device/vendor/kernel repositories
git clone https://github.com/han-senpai/device_google_coral device/google/coral -b bka
git clone https://github.com/Hans982/android_device_google_gs-common device/google/gs-common -b lineage-23.0
git clone https://github.com/han-senpai/kernel_google_msm-4.14 kernel/google/msm-4.14 -b bka
git clone https://github.com/han-senpai/vendor_google_flame vendor/google/flame -b bka

# Build Environment
export BUILD_USERNAME=Hans982; \
export BUILD_HOSTNAME=crave; \
export TZ=Asia/Tokyo; \

# Build
source build/envsetup.sh 
lunch infinity_flame-userdebug && m bacon
