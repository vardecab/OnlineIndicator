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
9. With a working internet connection, enable **Settings → General → Dev Flags →
   Force Offline**. Confirm that Wi-Fi still works in other apps, the menu
   bar shows offline, and the alert appears after the second failed check.
10. Disable test mode. Confirm that a successful real check hides the alert.
    Repeat with a real outage: disabling test mode must keep the alert visible
    until actual recovery.
11. Quit and relaunch while test mode is on. Confirm that test mode is off and
    real connectivity monitoring resumes.
12. On macOS 26+, confirm that the alert fits its icon, text, and arrow with modest
    padding, with no excess blank area. Confirm that its background is visibly
    pastel red while retaining native glass. Check it over both light and dark
    windows and in both system appearances.
13. While the alert is visible, change the system Liquid Glass appearance (where
    available), Reduce Transparency, and Increase Contrast. Confirm that the
    material follows macOS preferences and the label remains readable.
14. On macOS 14.6–15, confirm that the tinted vibrancy fallback appears correctly
    and that the same click and automatic dismissal behaviors still work.
15. Keep the original Online Indicator installed and running. Run
    `./build-and-run.sh`, then open `/Applications/Online Indicator X.app` in Finder.
    Confirm that X launches independently, with its own settings and menu bar item.
    Repeat after quitting both apps. The original must not launch when opening X.
16. With Force Offline enabled, compare the alert's icon and color to the menu bar.
    Change the No Network icon and color in Appearance while the alert is visible;
    both should update. Also test an internet probe failure with a working network
    interface: the alert must match the Blocked icon and color. Changing between
    Blocked and No Network during an outage should update the alert's icon.
17. Set the check interval to 60 seconds, enable Force Offline, and wait for the
    alert (or trigger a second check manually). With the alert visible, disable
    Force Offline while the real connection is unavailable. Restore internet
    access without changing the network interface. Confirm that recovery probes
    start every 3 seconds and the next successful check hides the alert. Verify
    that normal checks return to every 60 seconds and Settings still shows 60.
18. While the alert is visible, change the configured interval to 30 seconds.
    Confirm that recovery checks still run every 3 seconds; after recovery, normal
    checks must use the new 30-second interval. Repeat through a second outage.
19. Use an endpoint that never responds. Confirm that recovery requests time out
    after 2.5 seconds rather than being cancelled by the next timer tick. Keep the
    menu open and confirm that recovery checks continue.
20. Launch the app, disconnect, restore connectivity, toggle Wi-Fi, and switch
    networks. Confirm that no automatic status popovers appear beneath the menu
    bar icon. A manual Check Connection Now should dismiss its Checking popover
    when complete without showing a status popover.
21. With the alert visible, confirm that its outline matches the icon's configured
    color and the entire alert expands and contracts in a double heartbeat every
    1.8 seconds (7% on the first beat, 4% on the second). Confirm that the text,
    background, and border scale together, with no clipping or text reflow, in
    every screen position. Change the icon color and confirm the
    outline follows. Enable Reduce Motion while the alert is visible: the whole
    window should become steady. Disable Reduce Motion: the heartbeat should resume. Confirm the
    entire alert still opens Wi-Fi settings when clicked.
22. Check that Dev Flags shows “Force Offline” and uses the configured No Network
    icon and color. Customize the icon in Appearance and verify that the flag and
    alert both follow it.
23. While the alert is visible, select each Offline Alert position. Confirm that it
    moves immediately on the main display and stays clear of the notch, menu bar,
    and Dock. Test with the menu bar hidden and the Dock on different screen edges.
    Quit and relaunch to confirm the selected position persists. Reconnect an
    external display and confirm that the alert remains on screen.
