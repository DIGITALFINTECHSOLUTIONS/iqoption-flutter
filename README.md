# IQ Option Bot — Flutter Edition

A Flutter app that auto-taps the Higher button in IQ Option using image recognition and Android's Accessibility API. One codebase — works on Android now, iOS when Apple allows it.

---

## Build via GitHub Actions (no Flutter install needed)

```bash
git init && git add . && git commit -m "initial"
git remote add origin https://github.com/YOURUSER/iqoption-flutter.git
git push -u origin main
git tag v1.0.0 && git push --tags
```

Go to **GitHub → Actions** — APK builds automatically. Download from **Releases**.

---

## Build locally (optional)

```bash
flutter pub get
flutter build apk --debug
# APK at: build/app/outputs/flutter-apk/app-debug.apk
```

---

## Install on phone

1. Download `app-debug.apk`
2. Phone → Settings → Security → **Allow unknown sources**
3. Open APK → Install

---

## Setup

1. Open IQ Option first
2. Take a screenshot while the **Higher button is visible**
3. Crop it tightly around just the Higher button → save as PNG
4. Open IQ Option Bot → **Browse** → select that PNG
5. Set your interval → **START BOT**
6. Switch to IQ Option — the floating timer widget appears on top

---

## Permissions required

| Permission | Why |
|---|---|
| Overlay | Show floating widget on top of IQ Option |
| Accessibility Service | Tap the Higher button inside IQ Option |

---

## Architecture

```
lib/
├── main.dart                    Entry point
├── screens/
│   ├── home_screen.dart         Main UI (Bot + History + Settings tabs)
│   └── history_screen.dart      Trade history + CSV export
├── services/
│   ├── bot_service.dart         Bot logic + native channel bridge
│   ├── trade_log_service.dart   Trade recording + CSV export
│   └── settings_service.dart    Persistent settings
└── widgets/
    ├── stat_card.dart           Stat display card
    ├── interval_control.dart    Interval picker with presets
    ├── log_view.dart            Activity log
    └── permission_row.dart      Permission status row

android/app/src/main/kotlin/com/iqbot/flutter/
├── MainActivity.kt              Flutter ↔ Native bridge (MethodChannel)
├── BotAccessibilityService.kt   Screenshot + gesture tap engine
├── OverlayService.kt            Floating countdown widget
└── ImageUtils.kt                Template matching (pure Kotlin, no OpenCV)
```
