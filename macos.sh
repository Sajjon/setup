#!/usr/bin/env bash
# stolen from: https://github.com/why-jay/osx-init/blob/master/install.sh

defaults write com.apple.finder AppleShowAllFiles YES; # show hidden files
defaults write com.apple.dock persistent-apps -array; # remove icons in Dock
defaults write com.apple.dock tilesize -int 36; # smaller icon sizes in Dock
defaults write com.apple.dock autohide -bool true; # turn Dock auto-hidng on
defaults write com.apple.dock autohide-delay -float 0; # remove Dock show delay
defaults write com.apple.dock autohide-time-modifier -float 0; # remove Dock show delay
defaults write com.apple.dock orientation right; # place Dock on the right side of screen
defaults write NSGlobalDomain AppleShowAllExtensions -bool true; # show all file extensions

killall Dock 2>/dev/null;
killall Finder 2>/dev/null;

# install Xcode Command Line Tools
# https://github.com/timsutton/osx-vm-templates/blob/ce8df8a7468faa7c5312444ece1b977c1b2f77a4/scripts/xcode-cli-tools.sh
touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
PROD=$(softwareupdate -l |
  grep "\*.*Command Line" |
  head -n 1 | awk -F"*" '{print $2}' |
  sed -e 's/^ *//' |
  tr -d '\n')
softwareupdate -i "$PROD" -v;

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
brew install \
  caskroom/cask/brew-cask \
;
brew tap caskroom/versions;
brew cask install \
  java \
  google-chrome \
  dropbox \
  spectacle \
  flycut \
  contexts \
  flux \
  spotify \
  slack \
  sublime-text \
  vlc \
;


# Add default apps to dock
# Chrome
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Google Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
# Spotify
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Spotify.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
# Mail
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Mail.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

killall Dock 2>/dev/null;
killall Finder 2>/dev/null;

# Configure git
git config --global credential.helper osxkeychain; # activate git credentials storage
git config --global push.default simple; # default Git push behavior is set to `simple`
