# Radius Assist

A small macOS utility for calculating time-stretch ratios, pitch shifts, and tempo changes.

## Features

- Convert a stretch ratio (%) to the corresponding pitch shift in semitones.
- Convert between semitone shifts and stretch ratios.
- Calculate a target BPM from the original BPM and stretch ratio, or calculate the stretch ratio from two tempos.
- Enter ratios as percentages, decimal multipliers, or simple expressions such as `1/1.2` and `100/120`.

The calculator uses these relationships:

- `speed factor = 100 / stretch ratio (%)`
- `pitch shift (semitones) = 12 × log₂(speed factor)`
- `target BPM = source BPM / (stretch ratio / 100)`

## Requirements

- macOS 26.5 or later (as configured by the Xcode project)
- Xcode 27.1 or later to build from source

## Build

Open `Radius Assist.xcodeproj` in Xcode and build the **Radius Assist** scheme, or run:

```sh
xcodebuild -project "Radius Assist.xcodeproj" -scheme "Radius Assist" -configuration Release -destination 'platform=macOS' build
```

## Install

Download the DMG from the repository's Releases page, open it, and drag **Radius Assist.app** to Applications. The release build is ad-hoc signed and is not notarized; macOS may require you to approve the app in Privacy & Security on first launch.

## License

Apache License 2.0. See [LICENSE](LICENSE).
