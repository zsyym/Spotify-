#!/bin/bash
set -eu
cd "$(dirname "$0")/../.."
lyrics=Spotify/Player/Lyrics
output=$(mktemp -d)
bundle="$output/SCLyricsTests.xctest"
mkdir -p "$bundle/Contents/MacOS"
frameworks="$(xcrun --sdk macosx --show-sdk-platform-path)/Developer/Library/Frameworks"
cat > "$bundle/Contents/Info.plist" <<'PLIST'
<plist version="1.0"><dict><key>CFBundleExecutable</key><string>SCLyricsTests</string><key>CFBundleIdentifier</key><string>local.spotify.lyrics.tests</string><key>CFBundlePackageType</key><string>BNDL</string></dict></plist>
PLIST
xcrun --sdk macosx clang -bundle -fobjc-arc -fmodules -isysroot "$(xcrun --sdk macosx --show-sdk-path)" -F"$frameworks" -Wl,-rpath,"$frameworks" -framework Foundation -framework XCTest -I"$lyrics/Models" -I"$lyrics/Services" "$lyrics/Models/SCLyricsModel.m" "$lyrics/Services/SCLRCParser.m" "$lyrics/Services/SCLyricsTimeline.m" Tests/Lyrics/SCLyricsTests.m -o "$bundle/Contents/MacOS/SCLyricsTests"
xcrun xctest "$bundle"
