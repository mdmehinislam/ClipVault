# ClipVault

A local-first macOS text clipboard manager.

## Features in this starter build

- Clipboard text monitoring using NSPasteboard
- SwiftData local persistence
- Up to 500 unpinned history entries
- Pinned entries are excluded from automatic history cleanup
- Search, copy, pin/unpin, single delete, clear unpinned history
- Option+V global shortcut to open the popup
- Enter to paste the selected item (requires macOS Accessibility permission)

## Build on GitHub Actions from Windows

1. Create a GitHub repository named `ClipVault`.
2. Extract this ZIP on Windows.
3. Upload all files and folders in this directory to the repository root.
4. Commit to the `main` branch.
5. Open the repository's **Actions** tab.
6. Select **Build ClipVault for macOS**.
7. Click **Run workflow** and wait for the job to finish.
8. Open the completed workflow run and download `ClipVault-macOS-Installer`.
9. Extract the downloaded artifact. It contains `ClipVault.dmg`.

## Install on Mac

1. Open `ClipVault.dmg`.
2. Drag `ClipVault.app` to Applications.
3. Open ClipVault. An unsigned build may be blocked by Gatekeeper.
4. For a personally built app you trust, use Finder > Control-click the app > Open, if macOS offers that option.
5. Enable Accessibility for ClipVault under System Settings > Privacy & Security > Accessibility to allow simulated Command+V.

## Important notes

- This is an unsigned development build, not a notarized public release.
- Option+V is registered as a global shortcut in this starter version.
- macOS does not provide a reliable unrestricted way for an app to paste into every other app. Direct paste requires Accessibility permission and may behave differently in secure or protected apps.
- Clipboard monitoring polls NSPasteboard's changeCount. It does not recover clipboard history from before ClipVault was running.
- Clipboard contents may contain sensitive information. This starter stores clipboard text locally without encryption. Do not copy passwords or other secrets while monitoring is enabled.
- The shortcut UI, configurable retention limit, category management, and polished settings are planned follow-up work.
