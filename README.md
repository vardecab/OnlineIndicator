<p align="center">
  <img src=".github/assets/app-icon.png" alt="Online Indicator X icon" width="120" />
</p>

<h1 align="center">Online Indicator X</h1>

<p align="center">A macOS menu bar connection monitor with a persistent offline alert.</p>

<p align="center">
  <a href="https://github.com/vardecab/OnlineIndicator"><img src="https://img.shields.io/badge/version-1.6.0-blue" alt="Version 1.6.0" /></a>
  <img src="https://img.shields.io/badge/macOS-14.6%2B-grey?logo=apple" alt="macOS 14.6 or later" />
  <a href="https://github.com/vardecab/OnlineIndicator/blob/main/LICENSE"><img src="https://img.shields.io/github/license/vardecab/OnlineIndicator" alt="MIT license" /></a>
</p>

Maintained by [vardecab](https://github.com/vardecab). This fork builds on
[Online Indicator by bornexplorer](https://github.com/bornexplorer/OnlineIndicator)
and adds persistent outage alerts, faster recovery checks, and a separate macOS
app identity.

Current version: **1.6.0 (build 4)**.

## Features

- Menu bar indicators for connected, blocked, and no-network states.
- Custom SF Symbols, colors, labels, and saved icon sets for each state.
- A persistent “Network is down” alert after two consecutive failed checks.
- One-click access to Wi-Fi settings from anywhere on the alert.
- Configurable check interval and HTTP/HTTPS monitoring endpoint.
- Wi-Fi controls, optional network name display, local IPv4/IPv6 copying,
  customizable click actions, keyboard shortcuts, and launch at login.

The menu bar icon updates silently when connectivity changes. Automatic status
popovers are disabled.

## Offline alert and recovery

A failed internet probe or an unavailable network counts as a failure. After
**two consecutive failed checks**, the alert appears and stays visible across
desktops until a check succeeds. Manual checks count too. Clicking any part of
the alert opens **Wi-Fi settings**, where you can switch to a mobile hotspot or
another connection. Clicking does not dismiss the alert.

While the alert is visible, checks run every **3 seconds**, with a 2.5-second
timeout per probe. A successful check hides the alert and restores the interval
configured in Settings. Your saved interval is never overwritten; changing it
during an outage takes effect for normal monitoring after recovery.

The alert sizes itself to its content. Its icon and border color follow your
current connection-state preferences. A pastel red background uses native
**Liquid Glass on macOS 26+**, with a native vibrancy fallback on older systems.
The whole alert expands and contracts in a double heartbeat; **Reduce Motion**
disables the animation. macOS controls the native material's appearance and
accessibility adjustments.

In **Settings → General → Offline Alert → Position**, choose top left, under
notch/top center, top right, center, bottom left, bottom center, or bottom right.
The position is saved and updates a visible alert immediately on the main
display. Placement stays clear of the notch, menu bar, and Dock.

Connectivity is inferred from the chosen endpoint's HTTP response. The current
probe accepts HTTP 200–399 responses and does not validate captive-portal page
content, so some sign-in networks can appear connected.

## Build, install, and run

Requirements: **macOS 14.6+** and **Xcode 26.1+**, with full Xcode selected as the
active developer directory. Liquid Glass requires macOS 26 or later.

```bash
git clone https://github.com/vardecab/OnlineIndicator.git
cd OnlineIndicator
./build-and-run.sh
```

The script builds a Release app with local ad-hoc signing, verifies its signature
and bundle identity, installs it as `/Applications/Online Indicator X.app`, and
launches it. A paid developer account is not required for this local build. It
stops your running X copy before replacing it and restores the previous
installation if replacement fails. Installation may request an administrator
password through `sudo` if `/Applications` is not writable. Build output is in
`build/DerivedData`.

If Xcode is installed but not selected, select it in **Xcode → Settings →
Locations → Command Line Tools** before running the script.

X has its own bundle identifier, `com.vardecab.OnlineIndicatorX`, so it can coexist
with the original Online Indicator. Preferences, permissions, and launch-at-login
registration are separate. Rebuild to replace older X builds that shared the
original app's identity.

Prebuilt packages, when available, are listed on this fork's
[Releases page](https://github.com/vardecab/OnlineIndicator/releases). The local
build script does not notarize the app for distribution.

## Test the alert without disconnecting

1. Enable **Settings → General → Dev Flags → Force Offline**.
2. Wait for the next scheduled check, or use **Check Connection Now** as a click
   action to reach the second failure sooner. The alert then appears and recovery
   checks run every 3 seconds.
3. Try the alert positions and click anywhere on the alert to open Wi-Fi settings.
4. Turn Force Offline off. A successful real check hides the alert and restores
   normal monitoring. If the connection is still down, the alert stays visible.

Force Offline does not disconnect Wi-Fi and resets when the app quits. Its icon
and color match your configured No Network appearance.

See [the manual test checklist](Tests/offline-alert-manual.md) for recovery,
accessibility, animation, and display tests. On a Mac, run the policy and position
checks with:

```bash
swiftc 'Online Indicator/OfflineAlertPolicy.swift' \
  'Online Indicator/OfflineAlertPosition.swift' Tests/main.swift \
  -o /tmp/online-indicator-policy-tests
/tmp/online-indicator-policy-tests
```

Repository metadata checks use Python 3:

```bash
python3 -m unittest discover -s Tests -p 'test_*.py'
```

## Versioning

Releases follow SemVer (`MAJOR.MINOR.PATCH`) with a separate numeric build number.
The Xcode project's `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` are the
source of truth for Debug and Release. The source plist references those settings;
the menu bar and About screen read the built app's plist. No build step replaces
the version with a Git hash. Keep this README and its version badge in sync when
bumping the version.

## Privacy

- No analytics or usage tracking; preferences stay on your Mac.
- Connectivity probes contact `http://captive.apple.com` by default, or your
  chosen endpoint. That server receives a normal network request.
- Local IP addresses are read from network interfaces; no public-IP lookup
  service is used.
- Optional Wi-Fi name display requires Location Services permission on macOS.
  The app does not store or share your location.
- The custom offline alert does not require notification permission.

## Contributing and license

Report bugs and feature requests in
[vardecab/OnlineIndicator issues](https://github.com/vardecab/OnlineIndicator/issues).
For build failures, include the first compiler `error:` and nearby lines, your
Xcode/macOS versions, and the app version and build number.

Distributed under the [MIT License](LICENSE). Original copyright belongs to
bornexplorer; fork modifications are credited to vardecab. Original license
notices are retained.
