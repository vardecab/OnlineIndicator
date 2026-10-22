<p align="center">
  <img src=".github/assets/app-icon.png" alt="Online Indicator X" width="120" />
</p>

<h1 align="center">Online Indicator X</h1>

<p align="center">
A macOS menu bar app that replaces the Wi-Fi icon with customizable status indicators.
</p>
<br>
<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/platform-macOS-lightgrey?logo=apple&style=flat&color=%23FF5C60"></a>
  <a href="https://github.com/bornexplorer/OnlineIndicator/releases" target="_blank"><img src="https://img.shields.io/github/v/release/bornexplorer/OnlineIndicator?style=flat&color=%23FAC800"></a>
  <a href="https://github.com/bornexplorer/OnlineIndicator/blob/main/LICENSE" target="_blank"><img src="https://img.shields.io/github/license/bornexplorer/OnlineIndicator?style=flat&color=%2334C759"></a>
  <a href="https://ko-fi.com/bornexplorer" target="_blank"><img src="https://img.shields.io/badge/Ko--fi-FF5E5B?logo=ko-fi&logoColor=white"></a>
</p>
<br>



<img src=".github/assets/app-preview.png" alt="Online Indicator X Preview" width="100%" />

## Why Online Indicator X?

The macOS WiFi icon only shows that you are connected to a router, not whether your internet is actually working or being blocked. Online Indicator X replaces it with a live status icon that verifies real internet connectivity at the network level, so you can instantly see if you are online, offline, or blocked without opening any apps, giving you a smarter and slightly geekier way to understand your connection at a glance.

<br>

## Features

<img src=".github/assets/wifi.png" height="32" height="32" /><br>
**Ditch The Boring Wi-Fi Icon** <br>
Online Indicator X brings a smarter network experience to your menu bar with a live status icon that clearly shows your connection and gives you quick access to Wi Fi controls and settings.

<img src=".github/assets/palette.png" height="32" height="32" /><br>
**Make Every State Completely Yours!** <br>
Choose from 17 ready made Icon Sets or use any SF Symbol, set custom colors and labels for each state, and save your setup as your own Icon Set to switch anytime with a single tap.

<img src=".github/assets/icon.png" height="32" height="32" /><br>
**Your Icon, Your Rules.** <br>
Why should a menu bar icon only ever do one thing? With Online Indicator X, your left and right clicks each perform different actions and you can decide which does what. Swap them if the defaults do not feel right or disable custom actions entirely and just use the dropdown. You are always in control.

<img src=".github/assets/bolt.png" height="32" height="32" /><br>
**Fast and Simple Network Control** <br>
Control your Wi Fi connection and access network settings directly from the menu with a single click. Instantly view your current IP address with live updates and copy it to your clipboard for quick and easy sharing without needing additional tools or steps. For a more minimal and clean menu, the IP address display can also be turned off.

<img src=".github/assets/monitor.png" height="32" height="32" /><br>
**Flexible monitoring** <br>
Decide how often Online Indicator X checks your network by using the default presets or set your own custom interval. By default it pings Apple’s captive portal server, but you can point it to any URL you trust, whether your own server, company endpoint, or a custom address, ensuring reliable and flexible connectivity monitoring.

<img src=".github/assets/peek.png" height="32" height="32" /><br>
**Quick IP peek** <br>
Your IPv4 and IPv6 are always one click away in the menu. Tap to copy instantly, or hide them for a cleaner look.

<img src=".github/assets/keyboard.png" height="32" height="32" /><br>
**Keyboard Shortcuts** <br>
Set custom keyboard shortcuts to quickly toggle Wi Fi, open Wi Fi settings, and access network settings giving you faster control over your connectivity.

<br>

## Download & Install

### Offline alert

A custom alert appears in the top-right corner after two consecutive failed
connectivity checks. It stays visible across desktops while the network is
offline and disappears automatically after a successful check. Clicking anywhere on the alert opens
macOS Wi-Fi settings so you can switch to a mobile hotspot or another connection;
the alert stays visible until connectivity returns. No notification permission is
required.

The compact alert uses a pastel red tint over native Liquid Glass on macOS 26
and later. macOS controls the glass appearance using your system settings,
including accessibility adjustments. Earlier macOS versions use a native
vibrancy background with the same color wash. The window fits its content with
14-point horizontal and 12-point vertical padding. Its icon and color match the
menu bar's current connection state, including your appearance customizations.
An outline in the icon's color pulses gently while the alert is visible; Reduce
Motion keeps the outline steady. Connection changes update the menu bar icon
without showing additional status popovers.

A failed internet probe or an unavailable network counts as a failure. Manual
checks also count. Checks use your configured monitoring interval until the alert
appears. While it is visible, checks run every **3 seconds** to detect recovery
quickly, with a 2.5-second timeout per probe. A successful check hides the alert,
resets the failure counter, and restores your configured interval. Your saved
interval is never changed, even if you edit it during an outage.

To test without disconnecting, enable **Settings → General → Dev Flags → Force
Offline (Test)**. This immediately records a failed check; the next check uses
the configured interval and triggers the alert after the second failure. Turn
the toggle off to check the real connection again; a successful result hides the
alert. Test mode resets when the app quits.

### Build, install, and run from source

On a Mac with Xcode 26.1 or later installed and selected, run from this folder:

```bash
./build-and-run.sh
```

The script builds a Release app with local ad-hoc signing (no paid developer
account required), verifies its signature, replaces any existing
`/Applications/Online Indicator X.app`, and launches it. It stops your running copy
before replacement. If `/Applications` needs administrator access, `sudo` will
request your password for installation. Build output stays in `build/DerivedData`.

Online Indicator X uses its own bundle identifier, `com.vardecab.OnlineIndicatorX`,
so macOS distinguishes it from the original Online Indicator. Preferences,
launch-at-login registration, and permissions are separate. Rebuild and reinstall
with the script to replace an older X build that shared the original app's identity.

The current version is **1.5.1 (build 3)**. Versions follow SemVer
(`MAJOR.MINOR.PATCH`); the separate numeric build number identifies the build.
Update `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in both Debug and Release
configurations in the Xcode project for future releases. Builds use those values
directly rather than replacing the build number with a Git hash.

### 1 · Download
Head to the [**Latest Release**](../../releases/latest) page and grab the latest `.dmg` file.

### 2 · Install
Open the `.dmg` and drag **Online Indicator X** into your **Applications** folder. Done.

### 3 · First Launch

#### Option A — System Settings

1. Go to **System Settings → Privacy & Security**
2. Scroll down until you see Online Indicator X listed as blocked
3. Click **Open Anyway** and enter your password

#### Option B — Terminal

Paste this into Terminal and press Enter:
```bash
xattr -dr com.apple.quarantine /Applications/Online\ Indicator\ X.app
```
Then open the app normally.

> 💡 **Why does this happen?**
> Apple requires a $99/year developer certificate to "notarise" apps. Online Indicator X is free and independent, so it skips that. The warning is Apple's way of flagging uncertified apps, not a sign that anything is wrong.

<br>

## Privacy Policy

Online Indicator X collects no data. Period.

- No analytics, crash reporting or usage tracking
- No personal information collected or transmitted
- All preferences are stored locally on your Mac

The only outbound network request the app makes is the connectivity probe, a simple HTTP request to `captive.apple.com` (or your custom URL) to check if the internet is reachable. This is identical to what macOS itself does internally.

<br>

## License

[MIT License](LICENSE)
