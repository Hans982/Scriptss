#!/bin/bash

# ====== BUILD SECTION ======

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests

# Initialize repo for Matrixx
repo init -u https://github.com/ProjectMatrixx/android.git -b 15.0 --git-lfs

# Sync
/opt/crave/resync.sh

# Clone device/vendor/kernel repositories
git clone https://github.com/Hans982/android_device_google_coral device/google/coral -b Matrixx
git clone https://github.com/Hans982/android_device_google_gs-common device/google/gs-common -b lineage-22.2
git clone https://github.com/Hans982/android_kernel_google_msm-4.14 kernel/google/msm-4.14 -b lineage-22.2

# Build Environment
export BUILD_USERNAME=Hans982; \
export BUILD_HOSTNAME=crave; \
export TZ=Asia/Tokyo; \

# Build
source build/envsetup.sh 
brunch flame
