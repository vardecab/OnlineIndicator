# Custom offline alert verification (macOS)

Build and launch the app in Xcode. Use a short monitoring interval for these checks.

1. With internet access, confirm that no offline alert appears and no notification
   permission prompt is shown.
2. Disconnect the network. After two failed checks, confirm that one alert appears
   at the top right without taking focus from the current app.
3. Leave the network offline for several more checks. Confirm that the alert stays
   visible, including when switching apps, desktops, and a full-screen app.
4. Click the alert. Confirm that Network settings opens and the alert stays visible.
5. Connect to a working hotspot. Confirm that the next successful check hides the
   alert without requiring a click.
6. Disconnect again. Confirm that two new failed checks show the alert again.
7. Check that a single failure followed by recovery never shows the alert.
8. Disconnect an external display while the alert is visible. Confirm that the
   alert remains visible on an attached display.
9. With a working internet connection, enable **Settings → General → Monitoring →
   Force Offline (Test)**. Confirm that Wi-Fi still works in other apps, the menu
   bar shows offline, and the alert appears after the second failed check.
10. Disable test mode. Confirm that a successful real check hides the alert.
    Repeat with a real outage: disabling test mode must keep the alert visible
    until actual recovery.
11. Quit and relaunch while test mode is on. Confirm that test mode is off and
    real connectivity monitoring resumes.
