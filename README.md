# local_pip

A Flutter plugin for easily entering Picture-in-Picture (PiP) mode on both Android and iOS.

## Features

* ✅ Check if PiP is supported on the current device.
* ✅ Enter Picture-in-Picture mode with a single command.
* ✅ Responsive UI handling for tiny windows.

## Getting Started

### Android Setup

To allow your app to enter Picture-in-Picture mode, you must add `android:supportsPictureInPicture="true"` to the `MainActivity` in your `android/app/src/main/AndroidManifest.xml` file:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize"
    android:supportsPictureInPicture="true"> <!-- Add this line -->
```

### iOS Setup

To enable Picture-in-Picture support on iOS (iOS 15.0+):

1. **Enable Background Modes**: Open your iOS project in Xcode, navigate to your target's **Signing & Capabilities** tab, click **+ Capability**, and add **Background Modes**.
2. **Select picture-in-picture**: In the **Background Modes** checkbox list, check **Audio, AirPlay, and Picture in Picture** (this adds `audio` and `picture-in-picture` keys to your `Info.plist`'s `UIBackgroundModes`).

Alternatively, add this to your `ios/Runner/Info.plist` file inside the `<dict>` block:

```xml
<key>UIBackgroundModes</key>
<array>
	<string>audio</string>
	<string>picture-in-picture</string>
</array>
```

### Installation

Add `local_pip` to your `pubspec.yaml`:

```yaml
dependencies:
  local_pip: ^1.0.0
```

## Usage

### 1. Initialize the plugin
```dart
final _localPipPlugin = LocalPip();
```

### 2. Check for availability
PiP is available on Android 8.0 (API level 26) and above.
```dart
bool isAvailable = await _localPipPlugin.isPipAvailable();
```

### 3. Enter Picture-in-Picture
Call this method to shrink your app into the PiP window.
```dart
await _localPipPlugin.enterPipMode();
```

## Responsive Layout Tips

When the app enters PiP mode, the screen size shrinks drastically. You should use `LayoutBuilder` or `MediaQuery` to simplify your UI.

```dart
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final bool isPip = constraints.maxWidth < 300;
      
      return Scaffold(
        appBar: isPip ? null : AppBar(title: Text("My App")),
        body: Center(
          child: isPip 
            ? Icon(Icons.play_arrow) // Simplified UI for PiP
            : Column(children: [ ... ]), // Full UI
        ),
      );
    },
  );
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
