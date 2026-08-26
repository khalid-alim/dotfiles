#!/usr/bin/env bash

set -euo pipefail

delete_key() {
  defaults delete "$1" "$2" 2>/dev/null || true
}

echo restoring

for key in \
  KeyRepeat \
  InitialKeyRepeat \
  ApplePressAndHoldEnabled \
  com.apple.trackpad.scaling \
  AppleKeyboardUIMode \
  com.apple.mouse.tapBehavior \
  NSNavPanelExpandedStateForSaveMode \
  NSNavPanelExpandedStateForSaveMode2 \
  PMPrintingExpandedStateForPrint \
  PMPrintingExpandedStateForPrint2 \
  NSDocumentSaveNewDocumentsToCloud \
  AppleShowAllExtensions \
  com.apple.springing.enabled \
  com.apple.springing.delay; do
  delete_key NSGlobalDomain "$key"
done

for key in ShowStatusBar ShowPathbar _FXSortFoldersFirst FXDefaultSearchScope NewWindowTarget NewWindowTargetPath; do
  delete_key com.apple.finder "$key"
done

delete_key com.apple.AppleMultitouchTrackpad Clicking
delete_key com.apple.AppleMultitouchTrackpad FirstClickThreshold
delete_key com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag
delete_key com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking
delete_key com.apple.driver.AppleBluetoothMultitouch.trackpad FirstClickThreshold
delete_key com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag
defaults -currentHost delete NSGlobalDomain com.apple.mouse.tapBehavior 2>/dev/null || true

defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 30 \
  '{ enabled = 1; value = { parameters = (52, 21, 1179648); type = standard; }; }'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 31 \
  '{ enabled = 0; }'

for key in DSDontWriteNetworkStores DSDontWriteUSBStores; do
  delete_key com.apple.desktopservices "$key"
done

for key in \
  autohide \
  autohide-delay \
  autohide-time-modifier \
  mineffect \
  minimize-to-application \
  launchanim \
  show-process-indicators \
  show-recents \
  mru-spaces \
  scroll-to-open; do
  delete_key com.apple.dock "$key"
done

for key in \
  alternateDefaultShortcuts \
  subsequentExecutionMode \
  launchOnLogin \
  SUEnableAutomaticChecks \
  leftHalf \
  rightHalf \
  topHalf \
  bottomHalf \
  previousDisplay \
  nextDisplay; do
  delete_key com.knollsoft.Rectangle "$key"
done
killall Rectangle 2>/dev/null || true
open -ga Rectangle 2>/dev/null || true

for key in OpenMainWindow ShowCategory SortColumn SortDirection; do
  delete_key com.apple.ActivityMonitor "$key"
done

defaults -currentHost delete com.apple.ImageCapture disableHotPlug 2>/dev/null || true

killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

echo 'done'
