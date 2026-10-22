#!/bin/bash
# Build locally with ad-hoc signing, install in /Applications, and launch.
set -euo pipefail

if [[ "$(uname -s)" != Darwin ]]; then
    echo "This script requires macOS and the full Xcode app (26.1 or later)." >&2
    exit 1
fi

if ! xcodebuild -version >/dev/null 2>&1; then
    echo "Install Xcode 26.1 or later and select it with xcode-select before running this script." >&2
    exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
derived_data="$script_dir/build/DerivedData"
app_name="Online Indicator X.app"
expected_bundle_id="com.vardecab.OnlineIndicatorX"
built_app="$derived_data/Build/Products/Release/$app_name"
installed_app="/Applications/$app_name"

echo "Building Online Indicator X…"
xcodebuild \
    -project "$script_dir/Online Indicator.xcodeproj" \
    -scheme "Online Indicator" \
    -configuration Release \
    -destination 'platform=macOS' \
    -derivedDataPath "$derived_data" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY=- \
    DEVELOPMENT_TEAM= \
    build

if [[ ! -x "$built_app/Contents/MacOS/Online Indicator X" ]]; then
    echo "Build did not produce the expected application: $built_app" >&2
    exit 1
fi
/usr/bin/codesign --verify --deep --strict "$built_app"
built_bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$built_app/Contents/Info.plist")"
if [[ "$built_bundle_id" != "$expected_bundle_id" ]]; then
    echo "Refusing to install an app with unexpected bundle ID: $built_bundle_id" >&2
    exit 1
fi

# Elevate only the installation commands if /Applications is not writable.
install_command() {
    if [[ -w /Applications ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

staging_dir="$(install_command /usr/bin/mktemp -d /Applications/.online-indicator-install.XXXXXX)"
backup_app="$staging_dir/previous.app"
cleanup() {
    # Restore the previous installation if replacement failed after moving it.
    if [[ -d "$backup_app" && ! -e "$installed_app" ]]; then
        install_command /bin/mv "$backup_app" "$installed_app" || return
    fi
    install_command /bin/rm -rf "$staging_dir"
}
trap cleanup EXIT
# Keep staging inspectable by this user even when mktemp required sudo.
install_command /usr/sbin/chown "$(id -u):$(id -g)" "$staging_dir"

echo "Preparing installation…"
install_command /usr/bin/ditto "$built_app" "$staging_dir/$app_name"

# Stop the current user's running copy before replacing its bundle.
if /usr/bin/pgrep -u "$(id -u)" -f '/Online Indicator X[.]app/Contents/MacOS/Online Indicator X$' >/dev/null; then
    /usr/bin/pkill -u "$(id -u)" -f '/Online Indicator X[.]app/Contents/MacOS/Online Indicator X$' || true
    for ((attempt = 0; attempt < 50; attempt++)); do
        if ! /usr/bin/pgrep -u "$(id -u)" -f '/Online Indicator X[.]app/Contents/MacOS/Online Indicator X$' >/dev/null; then
            break
        fi
        sleep 0.1
    done
    if /usr/bin/pgrep -u "$(id -u)" -f '/Online Indicator X[.]app/Contents/MacOS/Online Indicator X$' >/dev/null; then
        echo "Quit Online Indicator X, then run this script again." >&2
        exit 1
    fi
fi

if [[ -e "$installed_app" ]]; then
    install_command /bin/mv "$installed_app" "$backup_app"
fi
install_command /bin/mv "$staging_dir/$app_name" "$installed_app"

echo "Launching $installed_app"
/usr/bin/open "$installed_app"
