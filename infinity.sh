#!/bin/bash

# ====== BUILD SECTION ======

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests

# Initialize repo for Infinity-X
repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault

# Sync
/opt/crave/resync.sh

# =======================
#   1. CLEANUP SECTION
# =======================

echo "Cleaning up cloned repositories..."
rm -rf hardware/google/camera
rm -rf device/google/gs-common
rm -rf device/google/coral
rm -rf vendor/google/flame
rm -rf kernel/google/msm-4.14

echo "Performing selective cleanup of 'out' directory..."
rm -rf out/target/product/flame/system
rm -rf out/target/product/flame/product
echo "Cleanup finished."

# Clone device/vendor/kernel repositories
git clone https://github.com/han-senpai/device_google_coral device/google/coral -b bka
git clone https://github.com/Hans982/android_device_google_gs-common device/google/gs-common -b lineage-23.0
git clone https://github.com/han-senpai/kernel_google_msm-4.14 kernel/google/msm-4.14 -b bka
git clone https://github.com/han-senpai/vendor_google_flame vendor/google/flame -b bka
git clone https://github.com/LineageOS/android_packages_apps_ElmyraService packages/apps/ElmyraService -b lineage-23.0

# Build Environment
export BUILD_USERNAME=Hans982; \
export BUILD_HOSTNAME=crave; \
export TZ=Asia/Tokyo; \

# Build
source build/envsetup.sh 
lunch infinity_flame-userdebug && m bacon
