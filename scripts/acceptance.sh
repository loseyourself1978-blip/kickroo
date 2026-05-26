#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

REPORT_DIR="$ROOT_DIR/reports/latest"
SCREENSHOT_DIR="$REPORT_DIR/screenshots"
DERIVED_DATA="$ROOT_DIR/DerivedData"
LOG_FILE="$REPORT_DIR/acceptance.log"
SCHEME="KickNations"
BUNDLE_ID="com.loseyourself1978.kickroo"

mkdir -p "$SCREENSHOT_DIR"
: > "$LOG_FILE"

log() {
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" | tee -a "$LOG_FILE"
}

run_step() {
  local name="$1"
  shift
  log "START $name"
  "$@" 2>&1 | tee -a "$LOG_FILE"
  log "PASS $name"
}

capture_screenshot() {
  local device_id="$1"
  local output_path="$2"
  local tmp_path
  tmp_path="/private/tmp/kickroo-$(basename "$output_path")"
  rm -f "$tmp_path"
  xcrun simctl io "$device_id" screenshot "$tmp_path"
  cp "$tmp_path" "$output_path"
}

select_device() {
  xcrun simctl list devices available | awk -F '[()]' '/iPhone/ && /Booted|Shutdown/ { print $2; exit }'
}

write_report() {
  local status="$1"
  local generated_at
  generated_at="$(date '+%Y-%m-%d %H:%M:%S')"
  cat > "$REPORT_DIR/index.html" <<HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Kickroo! Acceptance Report</title>
  <style>
    body { margin: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; background: #10131A; color: #F7F8FA; }
    main { max-width: 1120px; margin: 0 auto; padding: 24px; }
    h1 { margin: 0 0 4px; font-size: 30px; }
    .status { display: inline-flex; padding: 8px 12px; border-radius: 8px; background: ${status_color}; color: #111722; font-weight: 900; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 16px; margin-top: 20px; }
    .panel { background: #1A1F2B; border: 1px solid rgba(255,255,255,.08); border-radius: 8px; padding: 14px; }
    img { width: 100%; border-radius: 8px; background: #000; }
    pre { white-space: pre-wrap; word-break: break-word; max-height: 420px; overflow: auto; background: #0B1019; padding: 12px; border-radius: 8px; }
  </style>
</head>
<body>
  <main>
    <h1>Kickroo! Acceptance Report</h1>
    <p>Generated: ${generated_at}</p>
    <p><span class="status">${status}</span></p>
    <div class="grid">
      <section class="panel">
        <h2>Home</h2>
        <img src="screenshots/home.png" alt="Home screenshot">
      </section>
      <section class="panel">
        <h2>First Match Tutorial</h2>
        <img src="screenshots/tutorial.png" alt="Tutorial screenshot">
      </section>
      <section class="panel">
        <h2>Practice First</h2>
        <img src="screenshots/practice.png" alt="Practice match screenshot">
      </section>
      <section class="panel">
        <h2>Official Cup</h2>
        <img src="screenshots/cup.png" alt="Official cup screenshot">
      </section>
      <section class="panel">
        <h2>Result Share Poster</h2>
        <img src="screenshots/result-share.png" alt="Result screen share poster screenshot">
      </section>
    </div>
    <section class="panel">
      <h2>Log</h2>
      <pre>$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$LOG_FILE")</pre>
    </section>
  </main>
</body>
</html>
HTML
}

status_color="#F2C14E"
trap 'status_color="#F0524F"; write_report "FAILED"; log "FAILED acceptance"; exit 1' ERR

log "Kickroo! acceptance started"
DEVICE_ID="$(select_device)"
if [[ -z "$DEVICE_ID" ]]; then
  log "No available iPhone simulator found"
  exit 1
fi
log "Using simulator $DEVICE_ID"

xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE_ID" -b | tee -a "$LOG_FILE"

run_step "generate project" xcodegen generate
run_step "unit tests" xcodebuild -project KickNations.xcodeproj -scheme "$SCHEME" -destination "platform=iOS Simulator,id=$DEVICE_ID" -derivedDataPath "$DERIVED_DATA" test
run_step "debug build" xcodebuild -project KickNations.xcodeproj -scheme "$SCHEME" -destination "platform=iOS Simulator,id=$DEVICE_ID" -derivedDataPath "$DERIVED_DATA" build

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/Kickroo.app"
run_step "install app" xcrun simctl install "$DEVICE_ID" "$APP_PATH"
run_step "launch home" xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" -disableAudio
sleep 3
run_step "screenshot home" capture_screenshot "$DEVICE_ID" "$SCREENSHOT_DIR/home.png"

xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true
run_step "launch first tutorial" xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" -smokePractice -showTutorial -disableAudio
sleep 3
run_step "screenshot tutorial" capture_screenshot "$DEVICE_ID" "$SCREENSHOT_DIR/tutorial.png"

xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true
run_step "launch practice match" xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" -smokePractice -skipTutorial -disableAudio
sleep 4
screenshot_practice="$SCREENSHOT_DIR/practice.png"
run_step "screenshot practice" capture_screenshot "$DEVICE_ID" "$screenshot_practice"

xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true
run_step "launch official cup" xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" -smokeCup -skipTutorial -disableAudio
sleep 4
run_step "screenshot cup" capture_screenshot "$DEVICE_ID" "$SCREENSHOT_DIR/cup.png"

xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true
run_step "launch result share poster" xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" -smokeResult -disableAudio
sleep 2
run_step "screenshot result share poster" capture_screenshot "$DEVICE_ID" "$SCREENSHOT_DIR/result-share.png"

status_color="#17B978"
write_report "PASSED"
log "Kickroo! acceptance passed"
