#!/usr/bin/env bash

set -euo pipefail

echo applying

defaults write NSGlobalDomain KeyRepeat -int 0
defaults write NSGlobalDomain InitialKeyRepeat -int 5
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 5
defaults write NSGlobalDomain AppleKeyboardUIMode -int 2

defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad FirstClickThreshold -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 30 \
  '{ enabled = 0; }'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 31 \
  '{ enabled = 1; value = { parameters = (52, 21, 1179648); type = standard; }; }'

defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay -float 0.1
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
chflags nohidden "$HOME/Library"

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock scroll-to-open -bool true

defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
defaults write com.apple.ActivityMonitor ShowCategory -int 0
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -bool true
defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 1
defaults write com.knollsoft.Rectangle launchOnLogin -bool true
defaults write com.knollsoft.Rectangle SUEnableAutomaticChecks -bool true
defaults write com.knollsoft.Rectangle leftHalf -dict keyCode -int 38 modifierFlags -int 1179648
defaults write com.knollsoft.Rectangle rightHalf -dict keyCode -int 40 modifierFlags -int 1179648
defaults write com.knollsoft.Rectangle topHalf -dict keyCode -int 34 modifierFlags -int 1179648
defaults write com.knollsoft.Rectangle bottomHalf -dict keyCode -int 46 modifierFlags -int 1179648
defaults write com.knollsoft.Rectangle previousDisplay -dict keyCode -int 4 modifierFlags -int 1179648
defaults write com.knollsoft.Rectangle nextDisplay -dict keyCode -int 37 modifierFlags -int 1179648
killall Rectangle 2>/dev/null || true
open -ga Rectangle 2>/dev/null || true

killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

echo 'done'
