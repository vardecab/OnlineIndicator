# Custom offline alert verification (macOS)

Build and launch the app in Xcode. Use a short monitoring interval for these checks.

1. With internet access, confirm that no offline alert appears and no notification
   permission prompt is shown.
2. Disconnect the network. After two failed checks, confirm that one alert appears
   at the top right without taking focus from the current app.
3. Leave the network offline for several more checks. Confirm that the alert stays
   visible, including when switching apps, desktops, and a full-screen app.
4. With another app active, click the alert's icon, title, subtitle, arrow,
   padding, and empty space in separate attempts. Each first click must open
   Wi-Fi settings directly, and the alert must stay visible.
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
12. On macOS 26+, confirm that the alert is compact (320×88), has a soft red glass
    background, and shows the desktop through the native material. Check it over
    both light and dark windows and in both system appearances.
13. While the alert is visible, change the system Liquid Glass appearance (where
    available), Reduce Transparency, and Increase Contrast. Confirm that the
    material follows macOS preferences and the label remains readable.
14. On macOS 14.6–15, confirm that the tinted vibrancy fallback appears correctly
    and that the same click and automatic dismissal behaviors still work.
