# Building PlanList (Windows + Android)

`tool/build.ps1` wraps `flutter build` with the environment this project needs so
release builds are reproducible from one command.

## Quick start

```powershell
pwsh tool/build.ps1                 # release: Windows + Android
pwsh tool/build.ps1 -Target windows # release: Windows only
pwsh tool/build.ps1 -Target android # release: Android only
pwsh tool/build.ps1 -Mode debug     # debug builds
```

Artifacts:

| Target  | Path |
|---------|------|
| Android | `build/app/outputs/flutter-apk/app-release.apk` |
| Windows | `build/windows/x64/runner/Release/plan_list.exe` (ship the whole `Release/` folder) |

## Prerequisites

### 1. sqlite3 native libs (required, both platforms)

The `sqlite3` build hook is patched to read `SQLITE3_LOCAL_LIBS` and load the
prebuilt native libraries from there instead of downloading them at build time
(this project is often built behind a flaky network). Populate a directory with:

- Android: `arm64-v8a/`, `armeabi-v7a/`, `x86_64/` each containing `libsqlite3.so`
- Windows: `sqlite3.x64.windows.dll`

Default location is `C:\Android\sqlite3libs`. Override with `-Sqlite3Libs <dir>`
or by setting `$env:SQLITE3_LOCAL_LIBS`. The prebuilt libs are published on the
[`sqlite3` package releases](https://github.com/simolus3/sqlite3.dart/releases).

> The hook patch lives in the pub cache and is overwritten by `flutter pub get`
> / version bumps. If a build suddenly tries to download sqlite3, re-apply the
> patch (read `SQLITE3_LOCAL_LIBS` in `sqlite3/lib/src/hook/description.dart`).

### 2. Android SDK (one-time, Android only)

- Android SDK at `C:\Android\Sdk` (cmdline-tools, platform-tools, `android-36`,
  `build-tools;36.0.0`, `ndk;28.2.13676358`), licenses accepted.
- JDK 17, wired via `flutter config --jdk-dir "<jdk17>"`.
- `flutter config --android-sdk C:\Android\Sdk`.
- Gradle/Maven mirrors are configured for the flaky-network case
  (`android/gradle/wrapper/gradle-wrapper.properties`, `~/.gradle/init.gradle`).

### 3. Windows desktop (Windows only)

- Visual Studio with the **Desktop development with C++** workload
  (MSVC + Windows SDK + CMake). Verify with `flutter doctor`.

## Notes

- **Windows release was failing with an AOT `gen_snapshot` crash**
  (`exit code -1073740791`). Root cause was `flutter_local_notifications_windows`
  tree-shaking, fixed in app code by calling `getNotificationAppLaunchDetails()`
  during notification init — not a toolchain problem. See
  [issue #2615](https://github.com/MaikuB/flutter_local_notifications/issues/2615).
- Debug builds skip AOT, so `flutter build windows --debug` works even when the
  AOT path is broken — handy as a fallback while diagnosing.
