#!/bin/bash

# ╔════════════════════════════════════════╗
# ║         AxionOS Builder (.env)         ║
# ╚════════════════════════════════════════╝

# ========== Load local .env variables safely ==========
if [ -f .env ]; then
  set -o allexport
  source .env
  set +o allexport
else
  echo "❌ .env file not found!"
  exit 1
fi

# ========== Start timer ==========
START_TIME=$(date +%s)

# ========== Telegram notification: Build started ==========
curl -s -X POST https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage \
  --data-urlencode "chat_id=$TG_CHAT_ID" \
  --data-urlencode "text=🤔 *Build Started on Crave!*
📱 *Flame* by *Hans982" \
  --data-urlencode "parse_mode=Markdown"

# ========== Cleaning radio files ==========
echo -e "\e[1;35m🧹 Cleaning...\e[0m"
rm -rf .repo/local_manifests/ device/google/flame vendor/google/flame vendor/google/flame/radio \
echo -e "\e[1;32m✅ Clean complete.\e[0m"

# ========== Repo init ==========
repo init -u https://github.com/AxionAOSP/android.git -b lineage-22.2 --git-lfs || {
  curl -s -X POST https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage \
    --data-urlencode "chat_id=$TG_CHAT_ID" \
    --data-urlencode "text=❌ *Repo Init Failed!*" \
    --data-urlencode "parse_mode=Markdown"
  exit 1
}
echo -e "\e[1;32m✅ Repo initialized.\e[0m"

# ========== Repo sync ==========
/opt/crave/resync.sh || {
  curl -s -X POST https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage \
    --data-urlencode "chat_id=$TG_CHAT_ID" \
    --data-urlencode "text=❌ *Repo Sync Failed!*" \
    --data-urlencode "parse_mode=Markdown"
  exit 1
}
echo -e "\e[1;32m✅ Repo synced.\e[0m"

# ========== Clone sources ==========
git clone https://github.com/Hans982/android_device_google_coral -bAxion-os --depth 1 device/google/flame
git clone https://github.com/Hans982/android_device_google_gs-common -blineage-22.2 device/google/gs-common
git clone https://github.com/Hans982/android_kernel_google_msm-4.14 -blineage-22.2 --depth 1 kernel/google/msm-4.14
echo -e "\e[1;32m✅ Sources cloned.\e[0m"

# ========== Export build info ==========
export BUILD_USERNAME="Hans982"
export BUILD_HOSTNAME="crave"
export TZ="Asia/Tokyo"

# ========== Build Gapps ==========
rm -rf out/target/product/flame
source build/envsetup.sh
axion flame userdebug gms core
make installclean
ax -br || {
  curl -s -X POST https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage \
    --data-urlencode "chat_id=$TG_CHAT_ID" \
    --data-urlencode "text=❌ *Gapps Build Failed!*" \
    --data-urlencode "parse_mode=Markdown"
  exit 1
}
mv out/target/product/flame out/target/product/gapps

# ========== Telegram Done ==========
END_TIME=$(date +%s)
DURATION=$(( (END_TIME - START_TIME) / 60 ))

curl -s -X POST https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage \
  --data-urlencode "chat_id=$TG_CHAT_ID" \
  --data-urlencode "text=✅ *Build Finished Successfully!*
📱 *Flame*
😎🤙 Gapps: ✅
⏱️ Duration: *$DURATION min*" \
  --data-urlencode "parse_mode=Markdown"

# ========== Upload Function ==========
upload_latest_zip() {
  local path="$1"
  local variant="$2"

  zip_file=$(find "$path" -type f -iname "axion*.zip" -printf "%T@ %p\n" | sort -n | tail -n1 | cut -d' ' -f2-)

  if [[ -f "$zip_file" ]]; then
    echo -e "\e[1;36m⬆ Uploading $variant to Pixeldrain...\e[0m"
    response=$(curl -s -u ":$PIXELDRAIN_API_KEY" -X POST -F "file=@$zip_file" https://pixeldrain.com/api/file)

    file_id=$(echo "$response" | jq -r '.id')
    file_name=$(basename "$zip_file")
    file_size_bytes=$(stat -c%s "$zip_file")
    file_size_human=$(numfmt --to=iec --suffix=B "$file_size_bytes")
    upload_date=$(date +"%Y-%m-%d %H:%M")

    if [[ "$file_id" != "null" && -n "$file_id" ]]; then
      download_url="https://pixeldrain.com/u/$file_id"
      echo -e "\e[1;32m✅ $variant uploaded: $download_url\e[0m"

      curl -s -X POST https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage \
        --data-urlencode "chat_id=$TG_CHAT_ID" \
        --data-urlencode "text=✅ *$variant Uploaded!*

📎 *Filename:* \`$file_name\`
📦 *Size:* $file_size_human
🕓 *Uploaded:* $upload_date
🔗 [Download Link]($download_url)" \
        --data-urlencode "parse_mode=Markdown"
    else
      echo -e "\e[1;31m❌ Upload failed. Pixeldrain response:\n$response\e[0m"
      curl -s -X POST https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage \
        --data-urlencode "chat_id=$TG_CHAT_ID" \
        --data-urlencode "text=❌ *$variant Upload Failed!*
📦 Pixeldrain Error:
\`$response\`" \
        --data-urlencode "parse_mode=Markdown"
    fi
  else
    echo -e "\e[1;31m❌ No axion .zip found in $path for $variant\e[0m"
    curl -s -X POST https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage \
      --data-urlencode "chat_id=$TG_CHAT_ID" \
      --data-urlencode "text=❌ *$variant Upload Failed!*
📦 No axion .zip file found in \`$path\`." \
      --data-urlencode "parse_mode=Markdown"
  fi
}

# ========== Run Uploads ==========
upload_latest_zip "out/target/product/gapps" "Gapps"

# ========== Final echo ==========
echo -e "\e[1;32m🌟 Build finished in $DURATION minutes\e[0m"
