#!/bin/bash
# 检查简体中文本地化资源是否存在、语法合法，并确认关键界面文案 key 已覆盖。

set -euo pipefail

cd "$(dirname "$0")/../.."

readonly SETTINGS_FILE="src/apps/SettingsWindow/Resources/zh-Hans.lproj/Localizable.strings"
readonly EVENT_VIEWER_FILE="src/apps/EventViewer/Resources/zh-Hans.lproj/Localizable.strings"
readonly MENU_FILE="src/apps/Menu/Resources/zh-Hans.lproj/Localizable.strings"
readonly MULTITOUCH_FILE="src/apps/MultitouchExtension/Resources/zh-Hans.lproj/Localizable.strings"

# 校验指定 Localizable.strings 文件可以被 Apple plist 工具正常解析。
check_strings_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "missing localization file: $file" >&2
    exit 1
  fi

  plutil -lint "$file" >/dev/null
}

# 校验指定 Localizable.strings 文件包含关键英文 key，避免核心界面退回英文。
check_key() {
  local file="$1"
  local key="$2"

  if ! grep -F "\"$key\"" "$file" >/dev/null; then
    echo "missing localization key: $key ($file)" >&2
    exit 1
  fi
}

for file in "$SETTINGS_FILE" "$EVENT_VIEWER_FILE" "$MENU_FILE" "$MULTITOUCH_FILE"; do
  check_strings_file "$file"
done

check_key "$SETTINGS_FILE" "Simple Modifications"
check_key "$SETTINGS_FILE" "Devices"
check_key "$SETTINGS_FILE" "Setup"

check_key "$EVENT_VIEWER_FILE" "Main"
check_key "$EVENT_VIEWER_FILE" "Variables"
check_key "$EVENT_VIEWER_FILE" "Settings"

check_key "$MENU_FILE" "Profiles"
check_key "$MENU_FILE" "Settings..."
check_key "$MENU_FILE" "Quit Karabiner-Elements"

check_key "$MULTITOUCH_FILE" "Main"
check_key "$MULTITOUCH_FILE" "Power"
check_key "$MULTITOUCH_FILE" "Advanced"
